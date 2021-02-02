function [ModelInfo] = SingleGP_cubic(training_X,training_Y)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE
%   =====> Single-fidelity modeling
%
% Inputs:
%	training_X   - n x 1 vector of expensive sample locations
%   training_Y   - n x 1 vector of expensive sample responses
% Outputs:
%	ModelInfo    - Trained Gaussian Process model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
% Package: global optimization toolbox
% Ref: [1]  A. Forrester et al, Engineering Design via Surrogate Modelling:
% A Practical Guide, 2008, Wiley
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1-Training data preparation
ModelInfo.X = training_X;
ModelInfo.y = training_Y;

k=1;

UpperTheta = 2;
LowerTheta = -3;

[ModelInfo.Theta, MinNegLnLikelihood] = ...
    ga(@(x)likelihood_cubic(x,ModelInfo),k,[],[],[],[],LowerTheta,UpperTheta);

[NegLnLike,ModelInfo.Psi,ModelInfo.U,ModelInfo.SigmaSqr] = likelihood_cubic(ModelInfo.Theta,ModelInfo);

end

