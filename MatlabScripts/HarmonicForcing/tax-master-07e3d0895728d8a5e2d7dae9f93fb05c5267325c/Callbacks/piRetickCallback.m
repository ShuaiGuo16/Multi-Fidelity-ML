function piRetickCallback(hProp,eventData, axisLetter)    %#ok - hProp is unused
% piRetickCallback function is a callback for plots to adjust the angular
% ticks to multiples of pi.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% piRetickCallback(hProp,eventData, axisLetter);
% Input:        * hProp: 
%               * eventData: 
%               * axisLetter: 
% ------------------------------------------------------------------
% Authors:      Roel Mueller
% Last Change:  19 Nov 2012
% ------------------------------------------------------------------
% based on http://undocumentedmatlab.com/blog/setting-axes-tick-labels-format/

hAxes = eventData.AffectedObject;

curRange = get(hAxes, [upper(axisLetter), 'Lim']);
rangeRatio = log(curRange(2)-curRange(1))/log(10)-1.45;
% the last number corrects the tick density. More is denser.
stepSize = 10^ceil(rangeRatio) * pi;

if mod(rangeRatio,1)<.2
    stepSize = stepSize / 5;
elseif mod(rangeRatio,1)<.5
    stepSize = stepSize / 2;
end

set(hAxes, [upper(axisLetter), 'Tick'], ...
    ceil(curRange(1)/stepSize)*stepSize : ...
    stepSize : floor(curRange(2)/stepSize)*stepSize)

tickValues = get(hAxes, [upper(axisLetter), 'Tick'])/pi;

digits = 0;
labelsOverlap = true;
while labelsOverlap
    % Add another decimal digit to the format until the labels become distinct
    digits = digits + 1;
    format = sprintf('%%.%df pi',digits);
    newLabels = arrayfun(@(value)(sprintf(format,value)), ...
        tickValues, 'UniformOutput',false);
    labelsOverlap = (length(newLabels) > length(unique(newLabels)));
    
    % prevent endless loop if the tick values themselves are non-unique
    if labelsOverlap && max(diff(tickValues))< 16*eps
        break;
    end
end

set(hAxes, [upper(axisLetter), 'TickLabel'], newLabels);
end