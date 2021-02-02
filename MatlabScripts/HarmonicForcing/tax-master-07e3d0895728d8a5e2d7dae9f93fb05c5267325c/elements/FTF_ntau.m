function [sys,pars] = FTF_ntau(pars, ~)
% n-tau Flame model

N   = eval(cell2mat(pars.n));
tau = eval(cell2mat(pars.tau));

fMax = pars.fMax;
res = 10;
n = ceil(tau*fMax*res);
dTau = tau/n;

if (n==0)
    A=sparse(0,0);
    B=sparse(0,1);
    C=sparse(1,0);
    D=sparse(N);
else
    if (n==1)
        %First order
        fnf = [-1,0]; ff = -Duct.getCoeff(dTau,fnf);
        A = sparse(1:n, 1:n, ff(fnf==0),n,n) + sparse(2:n, 1:n-1, ff(fnf==-1),n,n);
        B(1,1) = ff(fnf==-1); % fu first input
    elseif (n==2)||(n==3)
        %Second order
        snf = [-2,-1,0]; sf = -Duct.getCoeff(dTau,snf);
        % Boundary: move stencil to fit in domain
        snfb = [-1,0,1]; sfb = -Duct.getCoeff(dTau,snfb);
        
        A = sparse(1:1, 1:1, sfb(snfb==0),n,n) +sparse(1,2,sfb(snfb==1),n,n)...
            + sparse(2:n, 2:n, sf(snf==0),n,n) + sparse(2:n, 1:(n-1), sf(snf==-1),n,n)...
            + sparse(3:n, 1:(n-2), sf(snf==-2),n,n);
        B(1,1) = sfb(snfb==-1); % fu first input
        B(2,1) = sf(snf==-2);
    else
        % Third order
        tnf = [1,0,-1,-2]; t = -Duct.getCoeff(dTau,tnf);
        % Boundary: Input move stencil to fit in domain
        tnfb = [2,1,0,-1];  tfb = -Duct.getCoeff(dTau,tnfb);
        % Boundary: Output move stencil to fit in domain
        tnfbo = [-3,-2,-1,0];  tfbo = -Duct.getCoeff(dTau,tnfbo);
        
        A = sparse(1, 1, tfb(tnfb==0),n,n) + sparse(1, 2, tfb(tnfb==1),n,n) + sparse(1, 3, tfb(tnfb==2),n,n)... % first 2 stencils input scheme
            +sparse(2:n-1, 2:n-1, t(tnf==0),n,n) + sparse(2:n-1, 1:(n-2), t(tnf==-1),n,n)... % intermediate stencils
            +sparse(3:n-1, 1:(n-3), t(tnf==-2),n,n) + sparse(2:n-1, 3:n, t(tnf==1),n,n)...
            +sparse(n, n, tfbo(tnfbo==0),n,n) + sparse(n, n-1, tfbo(tnfbo==-1),n,n)... % last stencil output scheme
            +sparse(n, n-2, tfbo(tnfbo==-2),n,n) + sparse(n, n-3, tfbo(tnfbo==-3),n,n);
        B = sparse(n,1);
        B(1,1) = tfb(tnfb==-1);
        B(2,1) = t(tnf==-2);
    end
    
    C = sparse(1,n,N,1,n);
    D = [];
end

sys = sss(A,B,C,D,[],0);

return

%% Testing against tf and pade approximation
FTF = tf(N,1,'InputDelay',tau);

FTFapprox = adaptTsAndDelays(FTF,0,fMax);
t = linspace(0,2*tau,10000);
figure
bode(sys,FTF,FTFapprox,linspace(0,fMax,1000)*2*pi);
figure
impulse(ss(sys),FTF,ss(FTFapprox),t)
figure
step(ss(sys),FTF,ss(FTFapprox),t)
