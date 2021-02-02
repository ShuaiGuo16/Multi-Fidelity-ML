function piRetick(axisName, axisLetters)
% piRetick function reticks an axis as multiples of pi and connects
% listener.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% piRetick(axisName, axisLetters);
% Input:        * axisName: 
%               * axisLetters: 
% ------------------------------------------------------------------
% Authors:      Roel Mueller
% Last Change:  19 Nov 2012
% ------------------------------------------------------------------

    for curLetter = axisLetters
%         disp(curLetter)handle.listener
% hListener = addlistener(handle(axisName), ...
%              findprop(handle(axisName),[curLetter, 'Lim']), 'PropertyPostSet', ...
%              {@piRetickCallback, curLetter});
         hListener = addlistener(axisName, ...
             findprop(handle(axisName),[curLetter, 'Lim']), 'PostSet', ...
             @(src,eventdata)piRetickCallback(src,eventdata, curLetter));
         setappdata(axisName, [curLetter, 'TickListener'], hListener);
    end
end