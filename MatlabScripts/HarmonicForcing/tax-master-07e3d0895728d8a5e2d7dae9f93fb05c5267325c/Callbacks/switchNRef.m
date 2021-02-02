function switchNRef(blockName,nRef)
% switchNRef function is a callback for simulink models to adjust the
% number of flame references using the gui.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% switchNRef(blockName,nRef);
% Input:        * blockName: handle of the simulink flame block
%               * nRef: number of desired references
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------

set_param(blockName, 'MaskSelfModifiable', 'on');

% Delete all superfluous flame reference ports
i=nRef+1;
while 1
    portname = [blockName '/virt' num2str(i)];
    try
        delete_block(portname);
        i= i+1;
    catch err %#ok<NASGU>
        break
    end
end

% Create the necessary number of reference ports
for i = 1: nRef
    pos = [1 1 31 15];
    orient = 'right';
    newport = 'built-in/Inport';
    portname = [blockName '/virt' num2str(i)];
    try
        add_block(newport,portname,'Position',pos,...
                'Orientation',orient);
    catch err %#ok<NASGU>
        continue
    end
end