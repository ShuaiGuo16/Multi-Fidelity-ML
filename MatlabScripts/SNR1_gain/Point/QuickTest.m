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
low_timelength = 0.12;    % 120ms for low-fidelity results
delta_t = data_timeseries.Ts;
max_freq = 500;
bootstrap = 1000;

%% 3-Reference FTF
Freq_plot=0:1:max_freq;
FIR_ref = modelPSD_v2.B{1};
[FTF_ref,~] = FTF_construct(FIR_ref, delta_t, Freq_plot');


% 4.1-LowFidelity results
scale = max_freq;    % Normalization const
[low, low_var] = LengthFIR_est(low_timelength, data_timeseries); % Obtain the low-fidelity results
[FTF_low, ~] = FTF_construct(low, delta_t, Freq_plot');

% Propagate FIR uncertainty to FTF
MC = 10000;
FIR_MC = mvnrnd(low,low_var,MC);
[FTF_MC,~] = FTF_construct(FIR_MC,delta_t,Freq_plot'); 
% low_std = std(FTF_MC,0,2);