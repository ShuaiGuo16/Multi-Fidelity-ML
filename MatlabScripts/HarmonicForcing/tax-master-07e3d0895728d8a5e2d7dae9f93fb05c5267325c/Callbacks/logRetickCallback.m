function logRetickCallback(hProp,eventData, axisLetter)    %#ok - hProp is unused
% logRetickCallback function is a callback for plots to adjust the
% freqeuncy ticks to logarithmic scaling.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% logRetickCallback(hProp,eventData, axisLetter);
% Input:        * hProp: 
%               * eventData: 
%               * axisLetter: 
% ------------------------------------------------------------------
% Authors:      Roel Mueller
% Last Change:  19 Nov 2012
% ------------------------------------------------------------------

hAxes = eventData.AffectedObject;

curRange = get(hAxes, [upper(axisLetter), 'Lim']);
set(hAxes, [upper(axisLetter), 'TickMode'], 'auto')
if curRange(2)/curRange(1) < 80 && ...
        strcmp(get(hAxes, [upper(axisLetter), 'Scale']),'log')
    % for this log-scaled axis, the ratio max/min is ticked badly by default.
    % increase to keep the default behaviour for larger ranges.
    rangeRatio = log(curRange(2)-curRange(1))/log(10);
    stepSize = 10^ceil(rangeRatio - 1); % Last term tunes tick density
    if mod(rangeRatio,1)<.2
        stepSize = stepSize / 5;
    elseif mod(rangeRatio,1)<.5
        stepSize = stepSize / 2;
    end
    
    set(hAxes, [upper(axisLetter), 'Tick'], round(curRange(1)/stepSize)*stepSize : ...
        stepSize : round(curRange(2)/stepSize)*stepSize)
else
    set(hAxes, [upper(axisLetter), 'Tick'], ...
        10.^(floor(log(curRange(1))/log(10)) : ...
        ceil(log(curRange(2))/log(10))))
    if curRange(2)/curRange(1) < 1e3
        set(hAxes, [upper(axisLetter), 'MinorGrid'], 'On')
    else
        set(hAxes, [upper(axisLetter), 'MinorGrid'], 'Off')
    end
end
end