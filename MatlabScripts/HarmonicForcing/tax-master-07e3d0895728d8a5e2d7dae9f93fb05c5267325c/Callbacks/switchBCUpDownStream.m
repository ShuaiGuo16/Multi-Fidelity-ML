function switchBCUpDownStream(blockName,location)
% switchBCUpDownStream function is a callback for simulink models to adjust
% the direction/orientation of 1D plane wave boundaries using the gui.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% switchBCUpDownStream(blockName,location);
% Input:        * blockName: handle of the simulink flame block
%               * location: Upstream or Downstream
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------

set_param(blockName, 'MaskSelfModifiable', 'on');
oldblock = [blockName '/Port'];

switch location
    case 'Upstream'
        if strcmp(get_param(oldblock,'BlockType'),'Inport')
            pos = get_param(oldblock,'Position');
            orient = get_param(oldblock,'Orientation');
        	delete_block(oldblock);
            newblock = 'built-in/Outport';
            add_block(newblock,oldblock,'Position',pos,...
                'Orientation',orient);
        end
        
    case 'Downstream'
        if strcmp(get_param(oldblock,'BlockType'),'Outport')
            pos = get_param(oldblock,'Position');
            orient = get_param(oldblock,'Orientation');
        	delete_block(oldblock);
            newblock = 'built-in/Inport';
            add_block(newblock,oldblock,'Position',pos,...
                'Orientation',orient);
        end
end
