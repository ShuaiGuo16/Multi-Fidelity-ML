function [data] = addNoise2Signal(data,uEx,noiseEx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add noise to the excitation signals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:
%       data:           velocity excitation signals
%       uEx:            name of the location with velocity excitation
%       noiseEx:      name of the location with noise excitation
% Outputs:
%       data:           velocity and noise excitation signals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.InputName = uEx;
% noise that is added to excitation signal is of type 'random gaussian
% white noise' and has the same time series length as the excitaion signal
data = [data iddata([],0.7*idinput(data.n,'rgs'),data.Ts,'Tstart',data.Tstart,'InputName',noiseEx)];

