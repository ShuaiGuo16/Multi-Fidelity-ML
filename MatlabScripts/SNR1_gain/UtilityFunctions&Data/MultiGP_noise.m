function [MultiFidelityModel] = MultiGP_noise(training_X,training_Y,training_Y_var,FIR,scale,delta_t,LoFi)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE
%    =====> Multi-fidelity modeling
%
% INPUTS
%	training_X   - n x 1 vector of high-fidelity sample locations
%   training_Y   - n x 1 vector of high-fidelity sample responses
%   training_Y_var - n x 1 variance of high-fidelity sample responses
%   FIR            - FIR coefficients, low-fidelity broadband identification 
%   scale          - maximum frequency range, for normalization
%   delta_t        - FIR model sampling interval
%   LoFi           - GP model for low-fidelity FFR curve
% OUTPUTS
%	MultiFidelityModel - Multi fidelity model for gain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
% Package: global optimization toolbox
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1-Training data preparation
MultiFidelityModel.X = training_X;
MultiFidelityModel.y = training_Y;
MultiFidelityModel.noise = diag(training_Y_var);

%% 2-Global optimization
% Use low-fidelity GP model parameters as the initial guessing
problem = createOptimProblem('fmincon',...
    'objective',@(x)likelihood_HK_noise(x,MultiFidelityModel,FIR,scale,delta_t),...
    'x0',[LoFi.Theta,LoFi.SigmaSqr],'options',...
    optimoptions(@fmincon,'Algorithm','sqp','Display','off'));
problem.lb = [-3;0];   problem.ub = [2;1];
gs = GlobalSearch('Display','off');
[x,fval] = run(gs,problem);

MultiFidelityModel.Theta = x(1);   
MultiFidelityModel.SigmaSqr = x(2);

[NegLnLike,MultiFidelityModel.Psi,MultiFidelityModel.U] = likelihood_HK_noise(x,...
    MultiFidelityModel,FIR,scale,delta_t);

end

