function [Likelihood_hist, Likelihood_mean] = Robust(ref, mu, sigma)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE
%       =====> Calculate log-likelihood 
% INPUTS
%       =====> ref: n x 1 vector (truth results, at each frequency)
%                   mu: n x 1 vector (predictive mean)
%                   sigma: n x 1 vector (predictive sigma)
% OUTPUTS
%       =====> Likelihood_hist: Likelihood value at each frequency
%       =====> Likelihood_mean: Averaged likelihood value for all
%       frequencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Likelihood_hist = 1./(sqrt(2*pi).*sigma).*exp(-(ref-mu).^2./(2.*sigma.^2));
% Geometric mean
Likelihood_mean = size(ref,1)*log10(geomean(Likelihood_hist));

end

