function [f]=pred_HK_noise(x, ModelInfo, FIR, scale, delta_t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE
%    =====> Calculates multi-fidelity predictions at x locations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS
%	x - m x k vetor of design variables
%   ModelInfo.X - n x k matrix of sample locations
%   ModelInfo.y - n x 1 vector of observed data
%   FIR         - FIR coefficients, serves as low-fidelity results
%   scale       - scale proper frequency range
%   delta_t     - sampling interval of FIR coefficients
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OUTPUTS
%	f - Multi-fidelity GP predictions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X=ModelInfo.X;
y=ModelInfo.y;
theta=10.^ModelInfo.Theta;
U=ModelInfo.U;

% calculate number of sample points
n=size(X,1);
one = ones(n,1);
Full_freq = 0:1:500;
[~,phase] = FTF_construct(FIR, delta_t, Full_freq');
% Use bode phase
for i = 1:n
    one(i) = phase(X(i)*scale==Full_freq');
end

% calculate mu
mu = (one'*(U\(U'\one)))\(one'*(U\(U'\y)));

% initialise psi to vector of ones
psi=ones(n,size(x,1));

for i=1:n
	for j=1:size(x,1)
		ksi=theta*abs(X(i)-x(j)); % abs added (February 10)
        if ksi>=1
            psi(i,j)=0;
        elseif ksi>0.2
            psi(i,j)=1.25*(1-ksi)^3;
        else
            psi(i,j)=1-15*ksi^2+30*ksi^3;
        end
	end
end

psi = psi*ModelInfo.SigmaSqr;

% calculate 
[~,phase_trend]=FTF_construct(FIR, delta_t, x*scale);
f=phase_trend*mu+psi'*(U\(U'\(y-one*mu))); 