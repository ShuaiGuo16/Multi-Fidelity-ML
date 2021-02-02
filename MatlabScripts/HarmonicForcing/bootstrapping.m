function [gain,phase] = bootstrapping(f,signal,start_time,Ts,repeat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  OBJECTIVE
%     ===> Obtain the confidence interval of harmonic exciation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  INPUTS 
%         =====> f:           nominal frequency (Hz)
%         =====> repeat:  number of boostrapping
%         =====> signal:   time series (u & Q), original data
%         =====> Ts:        sampling interval
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  OUTPUTS:
%         =====> gain:     {1}: nominal    {2}: bootstrap vector
%         =====> phase:  {1}: nominal    {2}: bootstrap vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1-Calculate the nominal
ini_val.u = [rms(signal.u),0];   ini_val.Q = [rms(signal.y),0]; 
[A_u, phi_u] = FitSin(f,signal.u,start_time,Ts,ini_val.u);
[A_Q, phi_Q] = FitSin(f,signal.y,start_time,Ts,ini_val.Q);
gain{1} = abs(A_Q/A_u);
phase{1} = phi_u-phi_Q;

%% 2-Bootstrapping
N = size(signal.u,1);
time = start_time:Ts:(N-1)*Ts+start_time;
error.u = A_u*sin(2*pi*f*time'+phi_u) - signal.u;
error.Q = A_Q*sin(2*pi*f*time'+phi_Q) - signal.y;
gain{2} = zeros(repeat,1); phase{2} = zeros(repeat,1);

for i = 1:repeat
    
    % Generate random numbers
    index.u = randi([1 N],1,N);
    index.Q = randi([1 N],1,N);
    dataNew.u = A_u*sin(2*pi*f*time'+phi_u) - error.u(index.u);
    dataNew.Q = A_Q*sin(2*pi*f*time'+phi_Q) - error.Q(index.Q);
 
        [A_ub, phi_ub] = FitSin(f,dataNew.u,start_time,Ts,[A_u,phi_u]);
        [A_Qb, phi_Qb] = FitSin(f,dataNew.Q,start_time,Ts,[A_Q,phi_Q]);
    
    gain{2}(i) = abs(A_Qb/A_ub);
    phase{2}(i) = phi_ub-phi_Qb;
    
end

end

