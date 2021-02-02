function [ e ] = RMSE(x,y)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE
%    =====> Calculate root-mean-square-error 
%                    between two vectors
% INPUT
%    =====> x: n x 1 vector
%           y: n x 1 vector
% OUTPUT
%    =====> e: RMSE error between x & y
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
e = sqrt(mean((x-y).^2));

end

