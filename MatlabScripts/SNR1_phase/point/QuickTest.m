clear
clc

% Load necessary data
load 'data4SysID_SNR1.mat'
load 'FIR_realizations.mat'
load 'modelPSD_v2.mat'

% Global parameters
low_timelength = 0.12;   
delta_t = data_timeseries.Ts;
max_freq = 500;
Freq_plot=0:1:max_freq;

% Reference FIR
FIR_ref = modelPSD_v2.B{1};
[~, phase_ref] = FTF_construct(FIR_ref, delta_t, Freq_plot');

% Low-fidelity results
[low, low_var] = LengthFIR_est(low_timelength, data_timeseries); % Obtain the low-fidelity results
[~,FTF_low] = FTF_construct(low,delta_t,Freq_plot'); 

% Get extreme FTF
[~,FTF_MC] = FTF_construct(FIR_MC,delta_t,Freq_plot'); 
index = find(FTF_MC(401,:)<-18);


figure(1)
t = delta_t:delta_t:30*delta_t;
hold on
stem(t,FIR_ref(2:end),'r','filled','LineWidth',1,'MarkerSize',6)
stem(t,low,'k','filled','LineWidth',1,'MarkerSize',6)
stem(t,FIR_MC(index(1),:),'g','filled','LineWidth',1,'MarkerSize',6)
hold off

xlabel('Time (s)','FontSize',14)
ylabel('FIR','FontSize',14)
h = gca;
h.FontSize = 14;
legend('Ref','Low-fidelity results','Extreme results')

figure(2)
hold on
plot(Freq_plot,phase_ref,'r','LineWidth',1.2)
plot(Freq_plot,FTF_low,'k','LineWidth',1.2)
plot(Freq_plot,FTF_MC(:,index(1)),'g','LineWidth',1.2)
hold off

xlabel('Frequency (Hz)','FontSize',14)
ylabel('Phase (rads)','FontSize',14)
h = gca;
h.FontSize = 14;
legend('Ref','Low-fidelity results','Extreme results')