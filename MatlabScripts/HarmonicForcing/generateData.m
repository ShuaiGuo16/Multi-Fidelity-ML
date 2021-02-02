function [dataFTF,SNR,noise_var] = generateData(sys,dataInput,uEx,noiseEx,uPrimeName,qPrimeName,modelPSD_new)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate time series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:
%       sys:            acoustic network system, state-space model
%       dataInput:     broadband excitation signals   
%       uEx:            name of the location with velocity excitation
%       noiseEx:      name of the location with noise excitation
%       uPrimeName:   u' channel
%       qPrimeName:   q' channe
%       modelPSD_new:   flame model + noise model 
% Outputs:
%       dataFTF:       u' and q' time series
%       SNR:             signal-to-noise ratio
%       noise_var:      variance of noise signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by M. Merk (TUM), Oct. 2016
% Email: merk@tfd.mw.tum.de
% Version: MATLAB R2015b
% Package: taX acoustic network calculator
% Ref: [1] S. Jaensch, M. Merk, T. Emmert, W. Polifke, Identification of
% flame transfer functions in the presence of intrinsic thermoacoustic
% feedback and noise, Combustion Theory and Modeling, 2018.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add noise to excitation signals
datau = addNoise2Signal(dataInput,uEx,noiseEx);
% Simulate acoustic network model
data = sim(sys,datau);
% Obtain the responsing u' and q' time series
dataFTF = iddata(data(:,qPrimeName,[]).y,data(:,uPrimeName,[]).y,data.Ts,'InputName','u','OutputName','q');

% Obtain system response under pure noise signals
datanoise = datau;
datanoise(:,[],'02f').u = zeros(size(datanoise(:,[],'02f').u));
modelPSD_new.InputName{1}='02f';
noise = sim(modelPSD_new,datanoise);
noise_var = var(noise.y);

sys.Blocks{getBlock(sys,'uPrime')};

% Obtain system response under pure velocity signals
datau(:,[],'v@y1').u = zeros(size(datau(:,[],'v@y1').u));
dataNoNoise = sim(sys,datau);
dataNoNoise = iddata(dataNoNoise(:,qPrimeName,[]).y,dataNoNoise(:,uPrimeName,[]).y,dataNoNoise.Ts,'InputName','u','OutputName','q');

% Calculate Signal-to-Noise value
SNR = var(dataNoNoise.y)./var(noise.y);   % Correct version



