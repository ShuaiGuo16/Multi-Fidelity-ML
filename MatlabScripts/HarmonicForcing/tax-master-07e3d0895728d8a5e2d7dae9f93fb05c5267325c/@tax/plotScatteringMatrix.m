function plotScatteringMatrix(varargin)
% Plot scattering matrix
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% plotScatteringMatrix(sys1,sys2,...sysN,freq);
% Input:        * sys1..N: tax objects
%               * freq: Frequency vector
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------
% See also tax/scatter

if isnumeric(varargin{end})
    freq = varargin{end};
    varargin(end) = [];
else
    freq = 2*pi*linspace(1,varargin{1}.fMax,100);
end

varargin = cellfun(@(x) x.scatter('dropIO') ,varargin,'UniformOutput',false);

varargin{end+1} = freq;

figure()
bode(varargin{:})