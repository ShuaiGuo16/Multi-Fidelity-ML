function logRetick(axisHandle, axisLetters)
% logRetick function is setting linear tick placement on log axes
% with a small range and connect listener.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% logRetick(axisHandle, axisLetters);
% Input:        * axisName: 
%               * axisLetters: 
% ------------------------------------------------------------------
% Authors:      Roel Mueller
% Last Change:  19 Nov 2012
% ------------------------------------------------------------------

for curLetter = axisLetters
    %         disp(curLetter)
    hListener = handle.listener(handle(axisHandle), ...
        findprop(handle(axisHandle), [curLetter, 'Lim']), 'PropertyPostSet', ...
        {@logRetickCallback, curLetter});
    setappdata(axisHandle, [curLetter, 'TickListener'], hListener);
end
end