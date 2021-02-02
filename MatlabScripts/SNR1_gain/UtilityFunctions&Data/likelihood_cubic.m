function [NegLnLike,Psi,U,SigmaSqr]=likelihood_cubic(x, ModelInfo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE
%    =====> Calculates the negative of the concentrated ln-likelihood
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS
%	x - vector of log(theta) parameters
%   ModelInfo.X - n x k matrix of sample locations
%   ModelInfo.y - n x 1 vector of observed data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OUTPUTS
%	NegLnLike - concentrated log-likelihood *-1 for minimising
%   Psi - correlation matrix
%	U - Choleski factorisation of correlation matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by A I J Forrester, 2007
% Version: MATLAB R2018b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X=ModelInfo.X;
y=ModelInfo.y;
theta=10.^x;
n=size(X,1);
one=ones(n,1);

% Pre-allocate memory
Psi=zeros(n,n);
% Build upper half of correlation matrix
for i=1:n
	for j=i+1:n
		ksi=theta*abs(X(i)-X(j)); % abs added (February 10)
        if ksi>=1
            Psi(i,j)=0;
        elseif ksi>0.2
            Psi(i,j)=1.25*(1-ksi)^3;
        else
            Psi(i,j)=1-15*ksi^2+30*ksi^3;
        end
	end
end

% Add upper and lower halves and diagonal of ones plus 
% small number to reduce ill-conditioning
Psi=Psi+Psi'+eye(n)+eye(n).*eps; 

% Cholesky factorisation
[U,p]=chol(Psi);

% Use penalty if ill-conditioned
if p>0
    NegLnLike=1e4;
else
    
    % Sum lns of diagonal to find ln(abs(det(Psi)))
    LnDetPsi=2*sum(log(abs(diag(U))));

    % Use back-substitution of Cholesky instead of inverse
    mu=(one'*(U\(U'\y)))/(one'*(U\(U'\one)));
    SigmaSqr=((y-one*mu)'*(U\(U'\(y-one*mu))))/n;
    NegLnLike=-1*(-(n/2)*log(SigmaSqr)-0.5*LnDetPsi);
end
