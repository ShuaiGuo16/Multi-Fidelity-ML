function adaptIO(blockName)
% adaptIO function is a callback to a simulink scatter block. It is
% adapting the number of inputs and outputs of the block by
% evaluating the values set in the gui.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% adaptIO(blockName);
% Input:        * blockName: tax object
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------

set_param(blockName, 'MaskSelfModifiable', 'on');

nIn = eval(get_param(blockName,'nIn'));
nOut = eval(get_param(blockName,'nOut'));

nPorts = nIn+nOut;
% Delete all superfluous ports
i=nPorts+1;
while 1
    portname = [blockName '/virt' num2str(i)];
    try
        delete_block(portname);
        i= i+1;
    catch err %#ok<NASGU>
        break
    end
end

% Create the necessary number of input and output ports
for i = 1: nPorts
    if i <= nIn
        BlockType = 'Inport';
    else
        BlockType = 'Outport';
    end
    pos = [1 1 31 15];
    orient = 'right';
    newport = ['built-in/',BlockType];
    portname = [blockName '/virt' num2str(i)];
    
    try
        if ~strcmp(get_param(portname,'BlockType'),BlockType)
            delete_block(portname);
            add_block(newport,portname,'Position',pos,...
                'Orientation',orient);
        end
    catch
        add_block(newport,portname,'Position',pos,...
            'Orientation',orient);
    end
end

end