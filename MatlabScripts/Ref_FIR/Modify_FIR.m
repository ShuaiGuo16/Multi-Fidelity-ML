clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  OBJECTIVE
%       ====> Construct target FIR with original noise filter 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
% Ref: [1] S. Jaensch, M. Merk, T. Emmert, W. Polifke, Identification of
% flame transfer functions in the presence of intrinsic thermoacoustic
% feedback and noise, Combustion Theory and Modeling, 2018.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('./data')

% Load full structure (FIR + noise filter)
load 'modelPSD_fit.mat'

% Target FIR parameters (Luis-Komarek)
N = 30;        % Non-zero numbers
delta_t = 4.5875e-4; 
flame_base = [3.5,8.5,9.4,0.6,0.5,0.8]/1000;
FIR_ref = FIR_coeff_filling(flame_base,N,delta_t);
FIR_ref = [0,FIR_ref];
save './data/FIR_ref.mat' FIR_ref

% Create new idpoly
A = 1; C = 1; D = 1;
B = cell(1,2); B{1,1} = FIR_ref; B{1,2} = modelPSD_fit.B{1,2};
F = modelPSD_fit.F;

Ts = modelPSD_fit.Ts;
NoiseVariance = modelPSD_fit.NoiseVariance;

modelPSD_v2 = idpoly(A,B,C,D,F,NoiseVariance,Ts,'InputName',{'u1','v@y1'},'OutputName',{'y1'});
save './data/modelPSD_v2.mat' modelPSD_v2