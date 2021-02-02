function [A, phi] = FitSin(f,signal,start_time,Ts,ini_val)
%%%%%%%%%%%%%%%
%   OBJECTIVE
%      ====> Fit signal in Sin shape
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   INPUTS
%        =====> f:                nominal frequency (Hz)
%        =====> signal:           time series
%        =====> start_time:       starting time for time series
%        =====> Ts:               sampling time step
%        =====> ini_val:          initial guessing for optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   OUTPUTS
%        =====> A:  FTF amplitude
%        =====> phi: FTF phase
%%%%%%%%%%%%%%%
x0 = ini_val;
N = size(signal,1);
time = start_time:Ts:(N-1)*Ts+start_time;
fun = @(x)sum((x(1)*sin(2*pi*f*time'+x(2))-signal).^2);
options = optimset('MaxFunEvals',2000,'MaxIter',2000,'TolFun',1e-7);
x = fminsearch(fun,x0,options);
A = x(1);   phi = x(2);

end

