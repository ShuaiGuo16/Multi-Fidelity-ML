clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE
%  ====> Test long-term FIR accuracy
%  ====> Generate Fig. 6(a)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('../UtilityFunctions&Data/')
addpath('../UtilityFunctions&Data/DataSet')

load 'data4SysID_SNR1.mat'
load 'modelPSD_v2.mat'

low_timelength = 1.4;     % Time series with sufficient length
delta_t = data_timeseries.Ts;
max_freq = 500;

% Reference FTF gain
Freq_plot=0:1:max_freq;
[FTF_ref,~] = FTF_construct(modelPSD_v2.B{1}, delta_t, Freq_plot');

% equivalent FTF gain
[low_equ,low_equ_var] = LengthFIR_est(low_timelength, data_timeseries);
[FTF_low_equ,~] = FTF_construct(low_equ, delta_t, Freq_plot');

% Propagate FIR uncertainty to FTF
MC = 1000;
FIR_MC = mvnrnd(low_equ,low_equ_var,MC);
[FTF_MC,~] = FTF_construct(FIR_MC,delta_t,Freq_plot'); 
low_equ_std = std(FTF_MC,0,2);


figure(1)
hold on
plot(Freq_plot,FTF_ref,'r','LineWidth',1.2)
plot(Freq_plot,FTF_low_equ,'k','LineWidth',1.2)
plot(Freq_plot,FTF_low_equ+low_equ_std,'k--','LineWidth',2)
plot(Freq_plot,FTF_low_equ-low_equ_std,'k--','LineWidth',2)
hold off

axis([0 500 0 2.4])
xticks(0:100:500)
yticks(0:0.6:2.4)
xlabel('Frequency (Hz)','FontSize',14)
ylabel('Gain','FontSize',14)
h = gca;
h.FontSize = 14;

legend('Reference','1400ms broadband results','$\pm 1\sigma$ confidence interval','Interpreter','latex')