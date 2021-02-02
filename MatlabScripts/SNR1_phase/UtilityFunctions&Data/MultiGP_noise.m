function [MultiFidelityModel] = MultiGP_noise(training_X,training_Y,training_Y_var,FIR,scale,delta_t)
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
% OUTPUTS
%	MultiFidelityModel - Multi fidelity model for phase
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

n=size(training_X,1);
phase_info = ones(n,1);
Full_freq = 0:1:500;
[~,phase] = FTF_construct(FIR, delta_t, Full_freq');

% Use bode phase
for i = 1:n
    phase_info(i) = phase(training_X(i)*scale==Full_freq');
end

%% 2-Global optimization
problem = createOptimProblem('fmincon',...
    'objective',@(x)likelihood_HK_noise(x,MultiFidelityModel,phase_info),...
    'x0',[0.3,3],'options',...
    optimoptions(@fmincon,'Algorithm','sqp','Display','off'));
problem.lb = [0.1;2];   problem.ub = [0.4;4];
gs = GlobalSearch('Display','off');
[x,fval] = run(gs,problem);

MultiFidelityModel.Theta = x(1);   
MultiFidelityModel.SigmaSqr = x(2);

[NegLnLike,MultiFidelityModel.Psi,MultiFidelityModel.U] = likelihood_HK_noise(x,...
    MultiFidelityModel,phase_info);

end

