clear
clc

load 'FTF_harmonic_SNR1_8C.mat'

% 1-reference FTF
load 'modelPSD_HiFreq.mat'
Freq_plot=0:1:500;
[gain, ~] = FTF_construct(modelPSD_HiFreq.B{1}, 1e-4, Freq_plot');

% Postprocessing
figure(1)
hold on

plot(Freq_plot,gain,'r','LineWidth',1.2)

f = 50:3:500;
% plot(f,min(FTF_gain{2}),'ko')
% plot(f,max(FTF_gain{2}),'ko')
errorbar(f,FTF_gain{1},3*std(FTF_gain{2}),'mo')
plot(f,FTF_gain{1},'mo')

hold off

legend('reference','Bootstrapping')
