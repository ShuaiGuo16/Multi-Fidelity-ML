function [MultiFidelityModel] = MultiGP_CI_noise_fix(training_X,training_Y,training_Y_var,FIR,scale,FidelityModel,delta_t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE
%   ====> Multi-fidelity modeling, focus on deriving confidence interval
%   ====> To improve the efficiency, multi-fidelity model given perturbed
%   training-set is not retained, but rather directly using the parameters 
%   of the nominal multi-fidelity GP model 
% INPUTS
%	training_X    - n x 1 vector of expensive sample locations
%   training_Y    - n x 1 vector of expensive sample responses
%   training_Y_var - n x 1 vector of training sample variance
%   FIR           - FIR coefficients, low-fidelity broadband identification 
%   scale         - Scale parameter to correct input range
%   FidelityModel - nominal multi-fidelity GP model
%   delta_t       - Sampling interval of FIR model
% OUTPUTS
%	MultiFidelityModel - Multi-fidelity model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1-Training data preparation
MultiFidelityModel.X = training_X;
MultiFidelityModel.y = training_Y;
MultiFidelityModel.noise = diag(training_Y_var);
MultiFidelityModel.Theta = FidelityModel.Theta;   
MultiFidelityModel.SigmaSqr = FidelityModel.SigmaSqr;
x = [MultiFidelityModel.Theta,MultiFidelityModel.SigmaSqr];

[NegLnLike,MultiFidelityModel.Psi,MultiFidelityModel.U] = likelihood_HK_noise(x,...
    MultiFidelityModel,FIR,scale,delta_t);

end