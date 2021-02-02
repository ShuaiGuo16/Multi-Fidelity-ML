function [sys] = getModel(sys)
% getModel function to extract a tax model from a simulink model.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% sys = getModel(sys);
% Input:        * sys: thermoacoustic network (tax) model
% Output:       * sys: thermoacoustic network (tax) model
%
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  27 Mar 2015
% ------------------------------------------------------------------

%% Read in blocks
systemList = find_system(sys.Name);
root = [systemList{1},'/'];
Connections = {};
for i = 2: length(systemList)
    hdl= char(systemList(i));
    [~,blockName] = fileparts(hdl);
    pars = [];
    pars.Name = blockName;
    pars.Ts = sys.Ts;
    pars.fMax = sys.fMax;
    % Read in the parameters of the Block
    parameterNames = get_param(systemList(i), 'MaskNames');
    
    for ii = 1:(size(parameterNames{1,1},1))
        parname = char(parameterNames{1,1}(ii));
        pars.(parname) = get_param(systemList(i), parname);
    end
    % Assure that the block contains an element parameter
    if isfield(pars,'element')
        %% Read in Connections
        % Create Connections structure
        % Get structure containing the port connection information
        ports = get_param(hdl,'portconnectivity');
        % Iterate over all ports of the current Block to retrieve connections
        for ii =  1:size(ports,1)
            iConnection = size(Connections,1) +1;
            % Evaluate the Block at which the port is pointing
            target = get_param(ports(ii,1).DstBlock,'name');
            
            % Check whether the port is pointing towards another block
            if ~isempty(target)
                % Write connection and local outport index
                Connections{iConnection,1} = char(blockName); % own identifyer
                Connections{iConnection,2} = ii;              % own port number
                Connections{iConnection,3} = target;          % target identifyer
                
                %%% Retrieve the port number of the target Block in this connection
                % Get the ports of the targeted Block
                portsTarget = get_param(char(strcat(root,target)),'portconnectivity');
                
                % Iterate over all ports of the target Block
                iinport = 0;
                for iii =  1:size(portsTarget,1)
                    % Get the name of the source Block of the current port of the target Block
                    SrcBlock = get_param(portsTarget(iii,1).SrcBlock,'name');
                    if ~isempty(SrcBlock)
                        % Check whether the current Block was the source on the
                        % target Block
                        if  strcmp(hdl,char(strcat(root,SrcBlock)))
                            % This ensures that if a Flame reference is
                            % directly connected to a flame, the code does not
                            % hick up.
                            if (ports(ii).DstPort +1 == iii)
                                % Add the local output index of the port to the connection
                                Connections{iConnection,4} = iii-iinport;
                            end
                        end
                    else
                        iinport = iinport+1;
                    end
                end
            end
        end
        %% Generate Block
        sys.Blocks{end+1} = feval(char(pars.element),pars);
    else
        error('This block does not have a mask.')
    end
end
BlocksList = cellfun(@(x) x.Name, sys.Blocks, 'UniformOutput', false);

%% Sort Connections
sys.Connections = sys.sortConnections(Connections);