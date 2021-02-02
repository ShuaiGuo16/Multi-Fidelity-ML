function sys = updatesss(sys, sys_up)
% updatesss function to update a sparse state space model while preserving
% the type of the model.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% sys = tax(PathToModel);
% Input:        * sys: tax,Block or AcBlock object
%               * sys_up: sss object with updated properties
% Output:       * sys: tax,Block or AcBlock object with updated properties
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------
% See also adaptTsAndDelays

% Convert to sparse state space
sys_up = sss(sys_up);
sys_up = adaptTsAndDelays(sys_up,sys.Ts);

% Copy into object
sys.A = sys_up.A;
sys.B = sys_up.B;
sys.C = sys_up.C;
sys.D = sys_up.D;
sys.E = sys_up.E;
sys.Ts = sys_up.Ts;

if not(isempty(sys_up.y{1}))
    sys.y = sys_up.y;
end
if not(isempty(sys_up.u{1}))
    sys.u = sys_up.u;
end

Groups = sys_up.InputGroup;
if not(isempty(Groups))
    for group = fieldnames(Groups)'
        sys.InputGroup.(char(group)) = sys_up.InputGroup.(char(group));
    end
end
Groups = sys_up.OutputGroup;
if not(isempty(Groups))
    for group = fieldnames(Groups)'
        sys.OutputGroup.(char(group)) = sys_up.OutputGroup.(char(group));
    end
end
Groups = sys_up.StateGroup;
if not(isempty(Groups))
    for group = fieldnames(Groups)'
        sys.StateGroup.(char(group)) = sys_up.StateGroup.(char(group));
    end
end
if isstruct(sys_up.UserData)
    for field = fieldnames(sys_up.UserData)'
        sys.UserData.(char(field)) = sys_up.UserData.(char(field));
    end
end

end