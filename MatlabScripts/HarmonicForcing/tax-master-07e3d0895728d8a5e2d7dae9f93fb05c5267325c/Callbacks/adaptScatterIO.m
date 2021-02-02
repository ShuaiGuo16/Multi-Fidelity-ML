function adaptScatterIO(blockName)
% adaptScatterIO function is a callback to a simulink scatter block. It is
% automatically adjusting the number of inputs and outputs of the block by
% evaluating the model to be loaded.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% adaptScatterIO(blockName);
% Input:        * blockName: tax object
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------

set_param(blockName, 'MaskSelfModifiable', 'on');

fileName = get_param(blockName,'filename');
modelName = get_param(blockName,'modelname');

% Load file:
try
    load(char(fileName));
catch err
    warning('Loading of scattering model file has failed.')
    error(err);
end
    
% evaluate model:
try
    sys = eval(char(modelName));
catch err
    warning('Evaluating of scattering model has failed.')
    error(err);
end

if (size(sys,1)~=size(sys,2))
    warning('This is not a proper scattering matrix!')
    return
end

nPorts = size(sys,1);

nIn = sum(cell2mat(cellfun(@(x) x.Mach<0, sys.Connection, 'UniformOutput', false)));
nOut = sum(cell2mat(cellfun(@(x) x.Mach>0, sys.Connection, 'UniformOutput', false)));

if (nPorts~= nIn+nOut)
    warning('Number of Ports does not match number of mean quantities specified by the system')
    return
end

if ((sum(cell2mat(cellfun(@(x) x.Mach==0, sys.Connection, 'UniformOutput', false)))) > 0)
     warning('Mean flow velocity =0 does not specify direction! Use +-eps.')
    return
end
    
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

%% Define overall length
l = sys.state.x;
set_param(blockName,'l',num2str(l))

%% Define port properties
Mach = cell2mat(cellfun(@(x) x.Mach, sys.Connection, 'UniformOutput', false));
A = cell2mat(cellfun(@(x) x.A, sys.Connection, 'UniformOutput', false));
rho = cell2mat(cellfun(@(x) x.rho, sys.Connection, 'UniformOutput', false));
c = cell2mat(cellfun(@(x) x.c, sys.Connection, 'UniformOutput', false));

set_param(blockName,'A',['[',num2str(A),']'])
set_param(blockName,'Mach',['[',num2str(Mach),']'])
set_param(blockName,'rho',['[',num2str(rho),']'])
set_param(blockName,'c',['[',num2str(c),']'])