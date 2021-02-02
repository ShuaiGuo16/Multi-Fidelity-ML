function [axiss, linkedaxiss]= plotStateVector(varargin)
% plotStateVector function is a wrapper for ACBLOCK/PLOTSTATEVECTOR function
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% [axiss, linkedaxiss]= plotStateVector(sys, AcVec, name, unit, D);
% Input:        * sys: tax object
%               * AcVec: Vector of acoustic state quantity of tax model
%               computed by ACBLOCK/CALCPROPERTY
%               * name:  Name of the figure
%               * unit:  Units of the quantities plottet
%               * omega: Frequency vector corresponding to AcVec
%               * procedure: 'eigenmodes' if lines must be along spacial
%               axis or anything else e.g.'' for lines along frequency axis
% Output:       * axiss: axis handles
%               * linkedaxiss: linked axis object for synchronized
%               visualization
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------
% See also ACBLOCK/PLOTSTATEVECTOR, ACBLOCK/calcProperty

sys = varargin{1};
AcVec = varargin{2};
name = varargin{3};
unit = varargin{4};
omega = varargin{5};

if nargin >=6
    procedure = varargin{6};
else
    procedure = '';
end

[axiss, linkedaxiss] = plotStateVector@AcBlock(sys, AcVec, name, unit, omega, sys.format, sys.freqScaling, sys.xScale, procedure);
end