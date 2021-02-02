clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE
%   ===>  Set up network model with reference FIR flame model
%  ===>   Harmonic forcing with auto-tuned amplitude
%  ===>   Generate databank for high-fidelity harmonic results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
% Package: taX acoustic network calculator
% Ref: [1] S. Jaensch, M. Merk, T. Emmert, W. Polifke, Identification of
% flame transfer functions in the presence of intrinsic thermoacoustic
% feedback and noise, Combustion Theory and Modeling, 2018.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialization
addpath('./data')
fMax = 5000;
sys = scatter(tax('BRS_Tay.slx',fMax));    % Load acoustic model
uPrimeName = 'u_uPrime_y';
qPrimeName = 'Q_uPrime';

% modelPSD_HiFreq contains both reference FIR model
% and colored noise model
load('modelPSD_HiFreq.mat')
newTF = modelPSD_HiFreq;
newTF.u = modelPSD_HiFreq.u;
newTF.y = modelPSD_HiFreq.y;
nb=120;

model4tax = ss(newTF);  % Convert to state-space model
FTFref = model4tax;
model4tax = sss(model4tax);
model4tax.y = {qPrimeName};
model4tax.u{1} = uPrimeName;
sys.Ts = model4tax.Ts;
%connect FTF and tax
sys = connect(sys,model4tax,{'02f',model4tax.u{2},'07g'}',{model4tax.y{1} ,uPrimeName,'07f_y','02g_y' }');

index = getBlock(sys,'scatter1');
uMean = sys.Blocks{index}.Connection{2}.Mach*sys.Blocks{index}.Connection{2}.c;
noiseEx = sys(:,'v@y1').u{1};
uEx  = '02f';

%% Harmonic Identification
Nimpulse = 500;
% Only identify frequencies at 50:3:500
f = 50:3:500;  f = f';
% Time length parameters and boostrap numbers
cycle = 8;  bootstrap = 1000;

time_step = sys.Ts;
time = 0:time_step:(Nimpulse*nb-1)*time_step;
FTF_gain{1} = zeros(size(f,1),1);     % Nominal value
FTF_gain{2} = zeros(bootstrap,size(f,1));    % Perturbed value, bootstrap(row), frequency(col)
FTF_phase{1} = zeros(size(f,1),1);     % Nominal value
FTF_phase{2} = zeros(bootstrap,size(f,1));    % Perturbed value, bootstrap(row), frequency(col)
SNR = zeros(size(f,1),1); 

for i = 1:size(f,1)
    
    forcing = sin(2*pi*f(i)*time);
    A_ini = 0.08;
    
    while A_ini > 0
        % Generate time series
        dataInput = iddata([],forcing'*uMean*A_ini,sys.Ts);
        disp('Starting simulation of tax model')
        [dataFTF_temp,SNR_temp,~] = generateData(sys,dataInput,...
            uEx,noiseEx,uPrimeName,qPrimeName,modelPSD_HiFreq);
        
        % Use the timeseries data starting from 1s
        begin_time = 1;    end_time = 1.3;
        selected_data = dataFTF_temp(floor(begin_time/sys.Ts):ceil(end_time/sys.Ts));

        if max(selected_data.u)<0.105   % Only check the selected data range

            dataFTF = dataFTF_temp;
            SNR(i) = SNR_temp;
            break
        else
            A_ini = A_ini - 0.002;
        end
    end
    
    % Harmonic identification
    begin_time = 1;    end_time = begin_time + cycle/f(i);
    selected_data = dataFTF(floor(begin_time/sys.Ts):ceil(end_time/sys.Ts));
    start_time = (floor(begin_time/sys.Ts)-1)*sys.Ts;
    disp('Starting harmonic identification')
    [gain,phase] = bootstrapping(f(i),selected_data,start_time,sys.Ts,bootstrap);
    FTF_gain{1}(i) = gain{1};    FTF_phase{1}(i) = phase{1};
    FTF_gain{2}(:,i) = gain{2};  FTF_phase{2}(:,i) = phase{2};

    A_ini
    
end

% save './data/FTF_harmonic_SNR1_8C.mat' FTF_gain FTF_phase 