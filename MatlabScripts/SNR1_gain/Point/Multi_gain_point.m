clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE
%     ===> Multi-fidelity modeling for gain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEPS
%    =====> (1) Derive low-fidelity FTF
%    =====> (2) Retrive high-fidelity FTF
%    =====> (3) Calculate multi-fidelity FTF
%    =====> (4) Determine uncertainties of multi-fidelity FTF
%    =====> (5) Calculate broadband FTF with an equivalent cost
%
%    Investigate the characteristics of MFGP approach (Sec. 3.2)
%    Generate Fig. 3(a), 4(a), 5(a)
%    All GP training is conducted using a normalized input range [0 1]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
% Ref: [1] S. Guo, C. F., Silva, W. Polifke, 'Robust Identification of 
%          Flame Frequency Response via Multi-fidelity Gaussian Process
%          Approach', 38th International Symposium on Combustion, 2020,
%          Adelaide, Australia.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1-Add path & load data
addpath('../UtilityFunctions&Data/')
addpath('../UtilityFunctions&Data/DataSet')
% Load time series & reference FIR model
load 'data4SysID_SNR1.mat'
load 'FTF_harmonic_SNR1_8C.mat'
load 'modelPSD_v2.mat'

%% 2-Global parameters
low_timelength = 0.12;    % 120ms for low-fidelity results
delta_t = data_timeseries.Ts;
max_freq = 500;
bootstrap = 1000;

%% 3-Reference FTF
Freq_plot=0:1:max_freq;
FIR_ref = modelPSD_v2.B{1};
[FTF_ref,~] = FTF_construct(FIR_ref, delta_t, Freq_plot');


%% 4-MultiFidelity training
% 4.1-LowFidelity results
scale = max_freq;    % Normalization const
[low, low_var] = LengthFIR_est(low_timelength, data_timeseries); % Obtain the low-fidelity results
FIR_samples = mvnrnd(low,low_var,bootstrap);
% Normalization: Gaussian
training_X_LoFi = 0:0.05:1;  training_X_LoFi=training_X_LoFi';
training_Y_LoFi =  FTF_construct(low, delta_t, training_X_LoFi*scale);
[FTF_low, ~] = FTF_construct(low, delta_t, Freq_plot');
[LoFi] = SingleGP_cubic(training_X_LoFi,training_Y_LoFi);

% Propagate FIR uncertainty to FTF
MC = 1000;
FIR_MC = mvnrnd(low,low_var,MC);
[FTF_MC,~] = FTF_construct(FIR_MC,delta_t,Freq_plot'); 
low_std = std(FTF_MC,0,2);
        
% 4.2-High-fidelity training samples
training_X_Hal = [53;185;269;365;443;500]/500;
% Obtain the training responses (also include 0Hz)
[training_X_dim, training_Y, training_Y_var] = FindCloseFreq(FTF_gain,training_X_Hal*scale);
equ_time = CalTime(training_X_dim,8,0.012);         % Calculate time budget for HiFi

training_X = [0;training_X_dim/scale]; 
training_Y = [1;training_Y]; training_Y_var = [1e-6;training_Y_var];
% Calculate the equivalent time for broadband excitation
Cost = equ_time+low_timelength;

% 4.3-Multi-fidelity model
[MultiFidelityModel] = MultiGP_noise(training_X,training_Y,training_Y_var,low,scale,delta_t,LoFi);
% Nominal Prediction
FTF_multi = pred_HK_noise(Freq_plot'/scale,...
             MultiFidelityModel,low,scale,delta_t);
        
% Confidence interval
FTF_multi_boot = zeros(size(Freq_plot,2),bootstrap);
training_Y_boot = mvnrnd(training_Y,diag(training_Y_var),bootstrap);
training_Y_boot(:,1) = ones(bootstrap,1);
        % 4.4-Start boostrapping
        for i = 1:bootstrap

             % Training multi-fidelity model
              [MultiFidelityModel_boot] = MultiGP_CI_noise_fix(training_X,training_Y_boot(i,:)',...
                        training_Y_var,FIR_samples(i,:),scale,MultiFidelityModel,delta_t);

              % Predictions of multi-fidelity model
               FTF_multi_boot(:,i) = pred_HK_noise(Freq_plot'/scale,MultiFidelityModel_boot,...
                        FIR_samples(i,:),scale,delta_t);
                    
               iterator = ['We are currently in',' ',num2str(i),' ','bootstrap']

        end
        [Upper,Lower] = ConfidenceBounds_symmetry(FTF_multi_boot,0.68,FTF_multi);

% 4.5-equivalent-Low-fidelity/confidence interval
full_time = low_timelength + equ_time;
[low_equ, low_equ_var] = LengthFIR_est(full_time, data_timeseries);
[FTF_low_equ, ~] = FTF_construct(low_equ, delta_t, Freq_plot');
        
% Propagate FIR uncertainty to FTF
MC = 1000;
FIR_MC = mvnrnd(low_equ,low_equ_var,MC);
[FTF_MC,~] = FTF_construct(FIR_MC,delta_t,Freq_plot'); 
low_equ_std = std(FTF_MC,0,2);
        
%% Post-processing
figure(1)
hold on

% Reference FTF gain
h1 = plot(Freq_plot,FTF_ref,'r','LineWidth',2);

% High-fidelity training samples 
h2 = errorbar(training_X_dim,training_Y(2:end),3*sqrt(training_Y_var(2:end)),'ro','MarkerSize',7,'MarkerFaceColor','r','CapSize',10);
plot(0,1,'bo','MarkerSize',7,'MarkerFaceColor','b')

% Multi-fidelity FTF gain
% plot(Freq_plot,FTF_multi,'b','LineWidth',1.2)
% plot(Freq_plot,Upper,'b--','LineWidth',1.2)
% plot(Freq_plot,Lower,'b--','LineWidth',1.2)

% Low-fidelity FTF gain
h3 = plot(Freq_plot,FTF_low,'k','LineWidth',2);
h4 = plot(Freq_plot,FTF_low+low_std,'k--','LineWidth',2);
plot(Freq_plot,FTF_low-low_std,'k--','LineWidth',2)

% Equivalent broadband FTF identification
% h3 = plot(Freq_plot,FTF_low_equ,'k','LineWidth',1.2);
% h4 = plot(Freq_plot,FTF_low_equ+low_equ_std,'k--','LineWidth',1.2);
% plot(Freq_plot,FTF_low_equ-low_equ_std,'k--','LineWidth',1.2)
hold off

axis([0 500 0 2.4])
xticks(0:100:500)
yticks(0:0.6:2.4)
xlabel('Frequency (Hz)','FontSize',14)
ylabel('Gain','FontSize',14)
h = gca;
h.FontSize = 14;
legend([h1 h2 h3 h4],{'Reference','Harmonic results','120ms broadband results','\pm 1\sigma confidence interval'})