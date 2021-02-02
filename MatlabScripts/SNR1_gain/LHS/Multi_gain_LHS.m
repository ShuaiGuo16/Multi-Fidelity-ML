clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE
%    =====> Investigate the sensitivity of 
%           harmonic excitation setting (Sec. 3.3)
%    =====> 20 replications of Latin-Hypercube samples
%    =====> High-fidelity samples of 6, 7, 8, 9
%    =====> Output (1) Nominal multi-fidelity FTF gain predictions
%                  (2) Likelihood of multi-fidelity predictions
%                  (3) Equivalent broadband results (nominal)
%                  (4) Equivalent broadband results (standard deviation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
% Package: Global optimization toolbox
% Ref: [1] S. Guo, C. F., Silva, W. Polifke, 'Robust Identification of 
%          Flame Frequency Response via Multi-fidelity Gaussian Process
%          Approach', 38th International Symposium on Combustion, 2020,
%          Adelaide, Australia.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1-Add path & load data
addpath('../UtilityFunctions&Data/')
addpath('../UtilityFunctions&Data/DataSet')
addpath('./data')
% Load time series & reference FIR model
load 'data4SysID_SNR1.mat'
load 'FTF_harmonic_SNR1_8C.mat'
load 'modelPSD_v2.mat'
load 'LHS_sample_20.mat'

%% 2-Global parameters
low_timelength = 0.12;   
delta_t = data_timeseries.Ts;
max_freq = 500;

%% 3-Reference FTF
Freq_plot=0:1:max_freq;
FIR_ref = modelPSD_v2.B{1};
[FTF_ref, ~] = FTF_construct(FIR_ref, delta_t, Freq_plot');


%% 4-MultiFidelity training
% 4.1-LowFidelity results
scale = max_freq;
[low, low_var] = LengthFIR_est(low_timelength, data_timeseries); % Obtain the low-fidelity results
training_X_LoFi = 0:0.05:1;  training_X_LoFi=training_X_LoFi';
training_Y_LoFi =  FTF_construct(low, delta_t, training_X_LoFi*scale);
[LoFi] = SingleGP_cubic(training_X_LoFi,training_Y_LoFi);
% Bootstrapping to obtain FIR samples (low-fidelity)
bootstrap = 1000;
FIR_samples = mvnrnd(low,low_var,bootstrap);

% Initial all the matrix
LHS_max = 20;
HF_sample_num_loop_max = 4;    

FTF_multi = zeros(size(Freq_plot,2),LHS_max,HF_sample_num_loop_max);
Std_Multi = zeros(size(Freq_plot,2),LHS_max,HF_sample_num_loop_max);
FTF_low_equ = zeros(size(Freq_plot,2),LHS_max,HF_sample_num_loop_max);
low_equ_std = zeros(size(Freq_plot,2),LHS_max,HF_sample_num_loop_max);
Cost = zeros(1,LHS_max,HF_sample_num_loop_max);
ref_likelihood = zeros(size(Freq_plot,2)-1,LHS_max,HF_sample_num_loop_max);

for HF_sample_num_loop = 1:HF_sample_num_loop_max    % Outer loop (HiFi sample numbers)
    
    for LHS_loop = 1:LHS_max  % Inner loop (LHS design)
        
        % 4.2-High-fidelity training samples
        training_X_LHS = LHS_sample_20{HF_sample_num_loop}(:,LHS_loop);
        % Obtain the training responses (also include 0Hz)
        [training_X_dim, training_Y, training_Y_var] = FindCloseFreq(FTF_gain,training_X_LHS*scale);
        training_X = [0;training_X_dim/scale]; training_Y = [1;training_Y]; training_Y_var = [1e-6;training_Y_var];
        % Calculate the time for HiFi
        equ_time = CalTime(training_X(2:end)*scale,8,0.012);         % Calculate time budget
        Cost(1,LHS_loop,HF_sample_num_loop) = equ_time+low_timelength;

        % 4.3-Multi-fidelity model
        [MultiFidelityModel] = MultiGP_noise(training_X,training_Y,training_Y_var,low,scale,delta_t,LoFi);

        % Nominal Prediction
        FTF_multi(:,LHS_loop,HF_sample_num_loop) = pred_HK_noise(Freq_plot'/scale,...
            MultiFidelityModel,low,scale,delta_t);

        % 4.4-Multi-fidelity model confidence interval (refit)
        FTF_multi_boot = zeros(size(Freq_plot,2),bootstrap);
                          
        % Generate perturbation on training_Y (for bootstrapping)
        training_Y_boot = mvnrnd(training_Y,diag(training_Y_var),bootstrap);
        training_Y_boot(:,1) = ones(bootstrap,1);

        % refit method to obtain CI
                for i = 1:bootstrap

                    % Training multi-fidelity model
                    [MultiFidelityModel_boot] = MultiGP_CI_noise_fix(training_X,training_Y_boot(i,:)',...
                        training_Y_var,FIR_samples(i,:),scale,MultiFidelityModel,delta_t);

                    % Predictions of multi-fidelity model
                    FTF_multi_boot(:,i) = pred_HK_noise(Freq_plot'/scale,MultiFidelityModel_boot,...
                        FIR_samples(i,:),scale,delta_t);
                    
                end
               

        % Extract useful info from bootstrapping data
        for freq_loop = 1:max_freq
            [ref_likelihood(freq_loop,LHS_loop,...
                HF_sample_num_loop),~] = ksdensity(FTF_multi_boot(freq_loop+1,:),FTF_ref(freq_loop+1));
        end  

        % 4.5-equivalent-Low-fidelity/confidence interval
        full_time = low_timelength + equ_time;
        [low_equ, low_equ_var] = LengthFIR_est(full_time, data_timeseries);
        [FTF_low_equ(:,LHS_loop,HF_sample_num_loop), ~] = FTF_construct(low_equ, delta_t, Freq_plot');

        % Propagate FIR uncertainty to FTF
        MC = 1000;
        FIR_MC = mvnrnd(low_equ,low_equ_var,MC);
        [FTF_MC,~] = FTF_construct(FIR_MC,delta_t,Freq_plot'); 
        low_equ_std(:,LHS_loop,HF_sample_num_loop) = std(FTF_MC,0,2);
    
    end
   
end

%% 5-Output results
% save './data/SNR1_gain_20.mat' FTF_multi ref_likelihood FTF_low_equ low_equ_std Cost 

