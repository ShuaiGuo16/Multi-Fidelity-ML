function sys = twoport(varargin)
% TWOPORT function to adjust names of inputs and outputs of 1D plane wave
% blocks with two ports and set up input and output groups.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% sys = oneport(sys);
% Input:        * sys: AcBlock twoport model
% Output:       * sys: AcBlock twoport model with IO names and groups
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------
% See also: tax/oneport

sys = varargin{1};
idxAcousticCon = [1,2];
if nargin==2
    idxAcousticCon= varargin{2};
end

%% Acoustic twoport element naming scheme
if (sys.Connection{idxAcousticCon(1)}.idx==0)
    % Upstream unconnected end (Scattering sys)
    sys.u{1} = ['f',sys.Name];
    sys.y{1} = ['g',sys.Name];
else
    sys.u{1} = [num2str(sys.Connection{idxAcousticCon(1)}.idx,'%02d'),'f'];
    sys.y{1} = [num2str(sys.Connection{idxAcousticCon(1)}.idx,'%02d'),'g'];
end

if (sys.Connection{idxAcousticCon(2)}.idx==0)
    % Downstream unconnected end (Scattering sys)
    sys.u{2} = ['g',sys.Name];
    sys.y{2} = ['f',sys.Name];
else
    sys.u{2} = [num2str(sys.Connection{idxAcousticCon(2)}.idx,'%02d'),'g'];
    sys.y{2} = [num2str(sys.Connection{idxAcousticCon(2)}.idx,'%02d'),'f'];
end

sys.InputGroup.f = 1;
sys.OutputGroup.f = 2;
sys.InputGroup.g = 2;
sys.OutputGroup.g = 1;
sys.StateGroup.(sys.Name) = 1:sys.n;