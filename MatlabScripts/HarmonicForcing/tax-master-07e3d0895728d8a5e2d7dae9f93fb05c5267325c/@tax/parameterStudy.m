function [J,combinations,Labels,models] = parameterStudy(sys,fun,varargin)
% parameterStudy function is iterating over a set of parameters in order to
% compute a function value of 
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% [J,combinations,Labels,models] = parameterStudy(sys,fun,varargin);
% Input:        * sys:       tax object
%               * fun:       function to be evaluated
%               * varargin:  linear cell containing the labels (odd
%               indices) and values (even) of parameters to be permuted
% Output:       * J:             function value evaluated on the tax models
%               * combinations:  parameter combinations used to compute
%               * Labels:        Identifiers of the permuted parameters
%               * models:        resulting tax models
% ------------------------------------------------------------------
% Authors:      Stefan Jaensch (jaensch@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------

% convert non-cell parameter values to cell (necessary for allcomb)
for i = 1:2:length(varargin)
    if ~iscell(varargin{i+1})
        varargin{i+1} = num2cell(varargin{i+1});
    end
end

combinations = allcomb(varargin{2:2:end});
[nCombs, ~] = size(combinations);


Labels = varargin(1:2:end);

J = cell(nCombs,1);
models = J;
for i = 1:nCombs    
    tmp = [Labels; combinations(i,:)];
    models{i} =changeParam(sys,tmp{:});
    models{i}.Name = [sys.Name '_' fSetName(combinations(i,:))];
end


tic
models{1} = update(models{1});
J{1} = fun(models{1});
t = toc;
disp(['Number of combinations: ' num2str(nCombs)])
disp(['Start time: ' datestr(now,'HH:MM:SS')])
disp(['Estimated computation time: ' datestr(datenum(0,0,0,0,0,t*nCombs),'DD:HH:MM:SS') ' (' num2str(t*nCombs) 's)'])
if t*nCombs>30
    parfor i = 2:nCombs
        [J{i},models{i}] = Loop(fun,models{i},combinations(i,:));
    end
else
    for i = 2:nCombs
        [J{i},models{i}] = Loop(fun,models{i},combinations(i,:));
    end
end
toc

end

function Name = fSetName(combinations)
Name = strjoin(cellfun(@num2str,combinations,'UniformOutput',false),'_');
end

function [J,model] = Loop(fun,model,combination)
try
    model = update(model);
    J = fun(model);
catch err
    J = [];
    warning(['Combination ' fSetName(combination) ' failed'] )
    disp(err.message)
end
end