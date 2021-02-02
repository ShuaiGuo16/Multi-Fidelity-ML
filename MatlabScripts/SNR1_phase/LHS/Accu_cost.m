clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE
% ====> Multi-fidelity post-processing
% ====> Calculate RMSE & Log-likelihood performance of both methods
% ====> Generate Fig. 8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
% Ref: [1] S. Guo, C. F., Silva, W. Polifke, 'Robust Identification of 
%          Flame Frequency Response via Multi-fidelity Gaussian Process
%          Approach', 38th International Symposium on Combustion, 2020,
%          Adelaide, Australia.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1-Add path & Load data 
addpath('../UtilityFunctions&Data/')
addpath('../UtilityFunctions&Data/DataSet')
addpath('./data')
load 'modelPSD_v2.mat'
load 'data4SysID_SNR1.mat'
data = load('SNR1_phase_20.mat');

%% 2-Calculate reference FTF
delta_t = data_timeseries.Ts;
max_freq = 500;

Freq_plot=0:1:max_freq;
[~, phase_ref] = FTF_construct(modelPSD_v2.B{1}, delta_t, Freq_plot');

%% 3-Calculate RSME
[~,LHS_loop,sample_loop] = size(data.FTF_multi);
Error.multi = zeros(sample_loop,LHS_loop); Error.LoFi = zeros(sample_loop,LHS_loop);
Lg_likelihood_mean.multi = zeros(sample_loop,LHS_loop); Lg_likelihood_mean.LoFi = zeros(sample_loop,LHS_loop);

for i = 1:sample_loop
    for j = 1:LHS_loop
        % Calculate RMSE
        Error.multi(i,j) = RMSE(data.FTF_multi(:,j,i),phase_ref)/(max(phase_ref)-min(phase_ref));
        Error.LoFi(i,j) = RMSE(data.FTF_low_equ(:,j,i),phase_ref)/(max(phase_ref)-min(phase_ref));
         % Calculate lg-likelihood
        Lg_likelihood_mean.multi(i,j) = sum(log10(data.multi_likelihood(:,j,i)));
        Lg_likelihood_mean.LoFi(i,j) = sum(log10(data.low_likelihood(:,j,i)));
%         [~, Lg_likelihood_mean.LoFi(i,j)] = Robust(phase_ref(2:end),data.FTF_low_equ(2:end,j,i),data.low_equ_std(2:end,j,i));
    end
end

%% 4-Postprocessing 
figure(1)
hold on

MarkerColor = {'b','g','m','c','y','k','r'};
for i = 1:sample_loop
    % Plot pure broadband
    plot(data.Cost(1,1:LHS_loop,i)*1000,Error.LoFi(i,:),'o','MarkerSize',8,...
        'MarkerFaceColor',[0.5,0.5,0.5],'MarkerEdgeColor',[0.5,0.5,0.5])
    % Plot Multi
    plot(data.Cost(1,1:LHS_loop,i)*1000,Error.multi(i,:),'>','MarkerSize',8,...
        'MarkerFaceColor',MarkerColor{i},'MarkerEdgeColor',MarkerColor{i})
end
hold off

axis([350 650 0 0.05])
xlabel('Time Length (ms)','FontSize',14)
ylabel('RMSE','FontSize',14)
h = gca;
h.FontSize = 14;

figure(2)
hold on

for i = 1:sample_loop
    % Plot pure broadband
    plot(data.Cost(1,1:LHS_loop,i)*1000,Lg_likelihood_mean.LoFi(i,:),'o',...
        'MarkerSize',8,'MarkerFaceColor',[0.5,0.5,0.5],'MarkerEdgeColor',[0.5,0.5,0.5])
    % Plot Multi
    plot(data.Cost(1,1:LHS_loop,i)*1000,Lg_likelihood_mean.multi(i,:),'>','MarkerSize',8,'MarkerFaceColor',MarkerColor{i},'MarkerEdgeColor',MarkerColor{i})
end
hold off

axis([350 650 -200 400])
xlabel('Time Length (ms)','FontSize',14)
ylabel('Lg-Likelihood','FontSize',14)
h = gca;
h.FontSize = 14;
