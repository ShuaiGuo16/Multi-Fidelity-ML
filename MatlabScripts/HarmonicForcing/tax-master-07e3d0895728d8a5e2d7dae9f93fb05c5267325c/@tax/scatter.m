function sys = scatter(varargin)
% scatter function removes parts of the system, that are not part of the
% scattering matrix specified by the user.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% sys = tax(PathToModel);
% Input:        * sys: tax object
%               * chars of scatteringDummy Block names to be used for
%               scattering matrix computation, with optional strings to
%               specify whether block sits at 'Upstream' or 'Downstream'
%               end of the desired part of the system
%               * 'dropIO': option to drop in- and outputs that are not
%               part of the scattering matrix
%               * 'SortConnections':  Sort and reindex the Connections
% Output:       * sys: tax object of scattering matrix
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------

sys = varargin{1};
scatBlockName = {};
loc={};
dropIO=0;
SortConnections = 0;

ii=0;
for i = 2:nargin
    if ischar(varargin{i})
        if strcmp(varargin{i},'SortConnections')
            SortConnections = 1;
        elseif strcmp(varargin{i},'dropIO')
            dropIO = 1;
        elseif not(strcmp(varargin{i},'Upstream')||strcmp(varargin{i},'Downstream'))
            ii=ii+1;
            scatBlockName{ii} = varargin{i};
            if i+1<=nargin
                if strcmp(varargin{i+1},'Upstream')||strcmp(varargin{i+1},'Downstream')
                    loc{ii} = varargin(i+1);
                end
            end
        end
    elseif iscell(varargin{i})
        scatCell = varargin{i};
        scatBlockName = scatCell(:,1);
        if size(scatCell,2)>0
            loc = scatCell(:,2);
        end
    end
end

if isempty(scatBlockName)
    scatBlockName = cellfun(@(x) x.Name,sys.Blocks(sys.getBlock('class','scatteringDummy')),'UniformOutput',false);
end

Connections = sys.Connections;

scatterBlocks = sys.Blocks(sys.getBlock(scatBlockName));

if not(isempty(loc)) % Override location/orientation of scattering blocks
    for ii = 1:length(loc)
        scatterBlocks{ii}.loc = loc{ii};
    end
end

if isempty(scatterBlocks)
    msgbox('There is no scattering block in the network.','Scattering block missing','warning');
end

head=[];
for i = 1: length(scatterBlocks)
    if strcmp(scatterBlocks{i}.loc,'Upstream')
        idx = scatterBlocks{i}.Connection{1}.idx;
        Connections{end+1,1} = Connections{idx,1}; Connections{idx,1} = '';
        Connections{end,2} = Connections{idx,2}; Connections{idx,2} = '';
        head = idx+1;
    else
        idx = scatterBlocks{i}.Connection{2}.idx;
        Connections{end+1,3} = Connections{idx,3}; Connections{idx,3} = '';
        Connections{end,4} = Connections{idx,4}; Connections{idx,4} = '';
        head = idx-1;
    end
end

% Sort Connections and truncate the superfluous ends
Connections = sys.sortConnections(Connections,head);

% Remove Blocks
Blocklist = unique([Connections(:,1);Connections(:,3)]);
sys.Blocks = sys.Blocks(sys.getBlock(Blocklist));

% Set new indices of connections
if SortConnections
    sys.Connections = sys.sortConnections(Connections);
end

% Update system
sys.uptodate= false; sys = sys.update;

if dropIO
    sys = sys.truncate(sys.OutputGroup.Scatter, sys.InputGroup.Scatter);
end