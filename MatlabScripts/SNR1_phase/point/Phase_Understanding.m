clear
clc

%% 1-Add path & load data
addpath('../UtilityFunctions&Data/')
addpath('../UtilityFunctions&Data/DataSet')
% Load time series & reference FIR model
load 'data4SysID_SNR1.mat'
load 'FTF_harmonic_SNR1_8C.mat'
load 'modelPSD_v2.mat'

%% 2-Global parameters
low_timelength = 0.12;   
delta_t = data_timeseries.Ts;
max_freq = 500;

%% 3-Reference FTF
Freq_plot=0:1:max_freq;
FIR_ref = modelPSD_v2.B{1};
[~, phase_ref,ref_wrap] = FTF_construct(FIR_ref, delta_t, Freq_plot');

%% 4-LowFidelity results
scale = max_freq;
[low, low_var] = LengthFIR_est(low_timelength, data_timeseries); % Obtain the low-fidelity results
[~,FTF_low,FTF_low_wrap] = FTF_construct(low,delta_t,Freq_plot'); 
MC = 1000;
FIR_MC = mvnrnd(low,low_var,MC);
[~,FTF_MC,FTF_MC_wrap] = FTF_construct(FIR_MC,delta_t,Freq_plot'); 
[FTF_MC_corr] = Phase_correct(FTF_MC,FTF_low);
% low_std = std(FTF_MC_corr,0,2);
% save 'FIR_realizations.mat' FIR_MC

figure(1)
hold on
plot(Freq_plot,ref_wrap,'r','LineWidth',2)
plot(Freq_plot,FTF_low_wrap,'b','LineWidth',1.2)
plot(Freq_plot,FTF_MC_wrap(:,1:3),'k--')
hold off


% figure(1)
% hold on
% h2=plot(Freq_plot,FTF_MC(:,1),'g');
% plot(Freq_plot,FTF_MC(:,2:200),'g')
% h1=plot(Freq_plot,FTF_low,'k','LineWidth',2);
% hold off
% axis([0 500 -24 0])
% xticks(0:100:500)
% yticks(-24:4:0)
% xlabel('Frequency (Hz)','FontSize',14)
% ylabel('Phase (rads)','FontSize',14)
% h = gca;
% h.FontSize = 14;
% legend([h1 h2],{'Nominal','Realizations'})
% 
% figure(2)
% hold on
% h2=plot(Freq_plot,FTF_MC_corr(:,1),'g');
% plot(Freq_plot,FTF_MC_corr(:,2:200),'g')
% h1=plot(Freq_plot,FTF_low,'k','LineWidth',2);
% hold off
% 
% legend('Nominal','Realizations')
% axis([0 500 -24 0])
% xticks(0:100:500)
% yticks(-24:4:0)
% xlabel('Frequency (Hz)','FontSize',14)
% ylabel('Phase (rads)','FontSize',14)
% h = gca;
% h.FontSize = 14;
% legend([h1 h2],{'Nominal','Realizations'})