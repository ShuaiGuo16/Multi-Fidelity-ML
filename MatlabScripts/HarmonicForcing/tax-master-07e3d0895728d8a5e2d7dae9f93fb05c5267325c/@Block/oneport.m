function sys = oneport(sys)
% ONEPORT function to adjust names of inputs and outputs of 1D plane wave
% boundary conditions and set up input and output groups.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% sys = oneport(sys);
% Input:        * sys: AcBlock boundary model
% Output:       * sys: AcBlock boundary model with IO names and groups
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------
% See also: tax/twoport

if(sys.Connection{1}.dir>0)
    %% Flow is directed out of the element
    sys.u{1} = [num2str(sys.Connection{1}.idx,'%02d'),'g'];
    sys.y{1} = [num2str(sys.Connection{1}.idx,'%02d'),'f'];
    sys.InputGroup.g = 1;
    sys.OutputGroup.f = 1;
else
    %% Flow is directed into the element
    sys.u{1} = [num2str(sys.Connection{1}.idx,'%02d'),'f'];
    sys.y{1} = [num2str(sys.Connection{1}.idx,'%02d'),'g'];
    sys.InputGroup.f = 1;
    sys.OutputGroup.g = 1;
end

sys.StateGroup.(sys.Name) = 1:sys.n;