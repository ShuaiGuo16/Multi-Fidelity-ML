clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE
%   ===> Generate u' & q' time series for system identification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETAILS
%   ===> Set up network model with reference FIR flame model
%   ===> Generate excitation signals and specify the locations to excite
%   ===> Simulate the network model under excitation signals
%   ===> Obtain the system response u' & q' signals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by M. Merk (TUM), Oct. 2016
% Email: merk@tfd.mw.tum.de
% Version: MATLAB R2015b
% Package: taX acoustic network calculator
% Ref: [1] S. Jaensch, M. Merk, T. Emmert, W. Polifke, Identification of
% flame transfer functions in the presence of intrinsic thermoacoustic
% feedback and noise, Combustion Theory and Modeling, 2018.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialization
fMax = 5000;  % Maximum frequency
sys = scatter(tax('BRS_Tay.slx',fMax));  % Load acoustic model
uPrimeName = 'u_uPrime_y';
qPrimeName = 'Q_uPrime';

% modelPSD_v2 contains both reference FIR model (truncated, only save the first 65 coefficients) 
% and colored noise model
load('./data/modelPSD_v2.mat')
newTF = modelPSD_v2;
newTF.u = modelPSD_v2.u;
newTF.y = modelPSD_v2.y;

model4tax = ss(newTF);  % Convert to state-space model
FTFref = model4tax;
model4tax = sss(model4tax);
model4tax.y = {qPrimeName};
model4tax.u{1} = uPrimeName;
sys.Ts = model4tax.Ts;
%connect FTF and tax
sys = connect(sys,model4tax,{'02f',model4tax.u{2},'07g'}',{model4tax.y{1} ,uPrimeName,'07f_y','02g_y' }');

index = getBlock(sys,'scatter1');
uMean = sys.Blocks{index}.Connection{2}.Mach*sys.Blocks{index}.Connection{2}.c;  % Obtain mean velocity
noiseEx = sys(:,'v@y1').u{1};   % Location to put noise excitation
uEx  = '02f';                            % Location to put velocity excitation

%% generate input excitation signals
Nimpulse = 100000;   % Time series total length
A = 0.05;   % Excitation amplitude
dataInput = iddata([],idinput(Nimpulse,'prbs')*uMean*A,sys.Ts);

%% simulate
disp('Starting simulation of tax model')
[data_timeseries,SNR,noise_var] = generateData(sys,dataInput,uEx,noiseEx,uPrimeName,qPrimeName,modelPSD_v2);
plot(data_timeseries)
% save './data/data4SysID_SNR1.mat' data_timeseries