function plotLoudspeakerResponse(sys)
% Plot the response of the system to excitation by a loudspeaker.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate
% thermoacoustic network systems. It is developed by the
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% plotLoudspeakerResponse(sys);
% Input:        * sys: thermoacoustic network (tax) model object
%
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  26 Jun 2015
% ------------------------------------------------------------------

if not(isfield(sys.InputGroup,'loudSpeaker'))
   warning('No Loudspeaker available.')
   return
end

freq = linspace(0,sys.fMax,200);
omega = 2*pi*(freq);

% Compute frequency response of entire system
Gf = freqresp(sys.truncate(sys.OutputGroup.f, sys.InputGroup.loudSpeaker), omega);
Gg = freqresp(sys.truncate(sys.OutputGroup.g, sys.InputGroup.loudSpeaker), omega);

for i = 1: length(sys.InputGroup.loudSpeaker)
    [AcVec, name, unit] = sys.calcProperty(squeeze(Gf(:,i,:)), squeeze(Gg(:,i,:)), sys.property);
    [result.axis, result.linkedaxis] = sys.plotStateVector(AcVec, name, unit, 1i*omega);
end

% Iterate over all Observers to generate dedicated plots
if isfield(sys.OutputGroup,'Observer')
    for i= 1:2:length(sys.OutputGroup.Observer)
        figure()
        bode(sys.truncate([sys.OutputGroup.Observer(i),sys.OutputGroup.Observer(i+1)], sys.InputGroup.loudSpeaker), omega);
    end
end