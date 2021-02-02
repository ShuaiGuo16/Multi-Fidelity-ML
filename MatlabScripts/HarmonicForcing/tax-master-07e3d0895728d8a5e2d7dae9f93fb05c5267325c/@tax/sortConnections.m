function Connections = sortConnections(varargin)
% sortConnections function to sort the connections of a tax model such that
% it is as linear as possible and eliminate connections unused by the
% model.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% sys = tax(PathToModel);
% Input:        * varargin{1}: tax object
%               * varargin{2}: Connections structure
%               * varargin{3}: optional: Index at which Connection to start
%                              sorting
% Output:       * Connections: sorted Connections structure
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------

sys = varargin{1};
Connections= varargin{2};

%% Separate Acoustic and non Acoustic Connections
NCon = size(Connections,1);
idxAcCon = 1:NCon;
idxNonAcCon = 1:NCon;
for i = NCon:-1:1
    if not(isempty(Connections{i,1}))
        idxPortu = Connections{i,2};
        if Block.isPort(sys.Blocks{sys.getBlock(['^',Connections{i,1},'$'])}.Connection(idxPortu),AcBlock.Port)
            idxNonAcCon(i) = [];
        else
            idxAcCon(i) = [];
        end
    elseif not(isempty(Connections{i,3}))
        idxPortd = Connections{i,4};
        if Block.isPort(sys.Blocks{sys.getBlock(['^',Connections{i,3},'$'])}.Connection(idxPortd),AcBlock.Port)
            idxNonAcCon(i) = [];
        else
            idxAcCon(i) = [];
        end
    else
        % Empty line in Connections
        idxNonAcCon(i) = [];
        idxAcCon(i) = [];
    end
end

NonAcConnections = Connections(idxNonAcCon,:);
Connections = Connections(idxAcCon,:);

%% Sort Acoustic Connections
% Initialize Index of Acoustic Connections
index = 1;
if nargin==3
    index=[];
    heads = varargin{3};
    for i = 1: length(heads)
        index = [index, find(idxAcCon==heads(i)), find(idxNonAcCon==heads(i))];
    end
end

leftHeads = index;
rightHeads = index;

% While there is still a head searching in left or right direction
while ~(isempty(leftHeads)&&isempty(rightHeads))
    %%% Left heads %%%
    if ~isempty(leftHeads)
        % Store the leading head in the index
        if isempty(find(index==leftHeads(1)))
            index = [leftHeads(1), index];
        end
        
        % Backward looking step find Connections right of the Left head
        if not(isempty(Connections{leftHeads(1),1}))
            temp = find(strcmp(Connections(:,1),Connections(leftHeads(1),1)));
        else
            temp = [];
        end
    
        % Keep only those connection indizes that are not already stored in the
        % index or in the right heads
        clearedTemp = [];
        for i = 1: length(temp)
            if isempty(find(index==temp(i)))&&isempty(find(rightHeads==temp(i)))
                clearedTemp = [temp(i) clearedTemp];
            end
        end
        % Append to right heads 
        rightHeads = [ rightHeads, clearedTemp];

        % Look for Connections left of the left block of the left head
        if not(isempty(Connections{leftHeads(1),1}))
            temp = find(strcmp(Connections(:,3),Connections(leftHeads(1),1)));
        else
            temp = [];
        end
        % Keep only those connection indizes that are not already stored in the
        % index or in the right heads
        clearedTemp = [];
        for i = 1: length(temp)
            if isempty(find(index==temp(i)))&&isempty(find(rightHeads==temp(i)))
                clearedTemp = [temp(i) clearedTemp];
            end
        end
    
        % Replace the leading head in leftHeads by the cleared temporary heads
        leftHeads(1) = [];
        leftHeads = [clearedTemp, leftHeads];
    end
    
    %%% Right heads %%%
    if ~isempty(rightHeads)
        % Store the leading head in the index
        if isempty(find(index==rightHeads(1)))
            index = [index, rightHeads(1)];
        end

        % Backward looking step right block of connection looking left
        if not(isempty(Connections{rightHeads(1),3}))
            temp = find(strcmp(Connections(:,3),Connections(rightHeads(1),3)));
        else
            temp = [];
        end
        % Keep only those connection indizes that are not already stored in the
        % index or in the left head
        clearedTemp = [];
        for i = 1: length(temp)
            if isempty(find(index==temp(i)))&&isempty(find(leftHeads==temp(i)))
                clearedTemp = [temp(i) clearedTemp];
            end
        end
        % Append to leftHeads
        leftHeads = [ leftHeads, clearedTemp];

        % rightHeads looking right
        if not(isempty(Connections{rightHeads(1),3}))
            temp = find(strcmp(Connections(:,1),Connections(rightHeads(1),3)));
        else
            temp = [];
        end
        % Keep only those connection indizes that are not already stored in the
        % index or in the left head
        clearedTemp = [];
        for i = 1: length(temp)
            if isempty(find(index==temp(i)))&&isempty(find(leftHeads==temp(i)))
                clearedTemp = [temp(i) clearedTemp];
            end
        end

        % Replace the leading Head in rightHeads by the cleared temporary heads
        rightHeads(1) = [];
        rightHeads = [clearedTemp, rightHeads];
    end
end

% Rearrange Connections structure
Connections = Connections(index,:);

%% Append non acoustic Connections if they are part of the acoustic system
% This will not work for more complex non acoustic connections
AcBlocks =  unique([Connections(:,1),Connections(:,3)]);
for i = 1: size(NonAcConnections,1)
    NonAcBlocks = unique([NonAcConnections(i,1),NonAcConnections(i,3)]);
    if sum(ismember(NonAcBlocks,AcBlocks))>0;
        Connections = [Connections;NonAcConnections(i,:)];
    end
end