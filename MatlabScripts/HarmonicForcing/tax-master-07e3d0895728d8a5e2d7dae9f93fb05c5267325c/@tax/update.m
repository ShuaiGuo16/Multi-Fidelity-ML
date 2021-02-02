function sys = update(sys)
% update function to update a tax object.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate
% thermoacoustic network systems. It is developed by the
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% sys = update(sys);
% Input:        * sys: thermoacoustic network (tax) model object
% Output:       * sys: thermoacoustic network (tax) model object
%
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  14 Apr 2015
% ------------------------------------------------------------------


if not(all(cellfun(@(x) x.uptodate,sys.Blocks)))||not(sys.uptodate)
    for i = 1:length(sys.Blocks)
        % Adapt fMax for all Blocks
        if isprop(sys.Blocks{i},'fMax')
            sys.Blocks{i}.fMax = sys.fMax;
        end
        sys.Blocks{i} = update(sys.Blocks{i});
    end
    sys.uptodate = false;
end

if sys.uptodate
    return
end
x0 = sys.x0;
sys = clear(sys);

%% Adapt Blocks and collect IOs
Blk = sys.Blocks;
Input = {};
Output = {};
for i = 1: length(Blk)
    % Adapt model type and sampling times
    Blk{i} = adaptTsAndDelays(Blk{i},sys.Ts);
    
%     if (not(isa(Blk{i},'ss'))) % Force ss toolbox
%         Blk{i} = ss(Blk{i});
%     end
    
    % Collect all inputs and outputs
    for InputGroupc = fieldnames(Blk{i}.InputGroup)'
        InputGroup = char(InputGroupc);
        Input = [Input; Blk{i}.u(Blk{i}.InputGroup.(InputGroup))]; %#ok<AGROW>
    end
    for OutputGroupc = fieldnames(Blk{i}.OutputGroup)'
        OutputGroup = char(OutputGroupc);
        Output = [Output; Blk{i}.y(Blk{i}.OutputGroup.(OutputGroup))]; %#ok<AGROW>
    end
end
Input = sort(unique(Input));
Output = sort(unique(Output));

%% Connect the acoustic system
Blk =[{sys},Blk];
sys = connect(Blk{:},Input,Output);
% sys.Blocks = Blk(2:end);

% Append postfix to ensure uniqueness of inputs and outputs for further
% connect() commands
sys.y  = cellfun(@(x) [x '_y' ],sys.y,'UniformOutput',false);

%% Generate state vectors for plotting acoustics
BlkList = cellfun(@(x) x.Name, sys.Blocks, 'UniformOutput', false);

len = length(sys.OutputGroup.f);
sys.state.x=zeros(1, len);sys.state.idx=zeros(1, len);
sys.state.rho=zeros(1, len);sys.state.c=zeros(1, len);
sys.state.Mach=zeros(1, len);sys.state.A=zeros(1, len);
idxX = 1;

% Initialize first value using upstream Block and downstream port
firstAcCon=1;
while (isempty(sys.Connections{firstAcCon,2}))
    firstAcCon = firstAcCon+1;
end

idxPort = cell2mat(sys.Connections(firstAcCon,2));
idxBlk = strcmp(char(sys.Connections(firstAcCon,1)),BlkList);
    
if (Block.checkPort(sys.Blocks{idxBlk}.Connection(idxPort), AcBlock.Port)&& isfield(sys.Blocks{idxBlk}.OutputGroup, 'f'))
    len = length(sys.Blocks{idxBlk}.OutputGroup.f)-1;
    sys.state.x(idxX:idxX+len)   = sys.Blocks{idxBlk}.state.x;
    sys.state.idx(idxX:idxX+len) = sys.Blocks{idxBlk}.state.idx;
    sys.state.rho(idxX:idxX+len) = sys.Blocks{idxBlk}.state.rho;
    sys.state.c(idxX:idxX+len)   = sys.Blocks{idxBlk}.state.c;
    sys.state.Mach(idxX:idxX+len)= sys.Blocks{idxBlk}.state.Mach;
    sys.state.A(idxX:idxX+len)   = sys.Blocks{idxBlk}.state.A;
    
    idxX = idxX+len+1;
end


for i = firstAcCon:(size(sys.Connections,1))
    if not(isempty(sys.Connections{i,3}))
        % Downstream Block
        idxPort = cell2mat(sys.Connections(i,4));
        idxBlk = strcmp(char(sys.Connections(i,3)),BlkList);
        
        % Ensure acoustic connection and downstream port
        if (Block.checkPort(sys.Blocks{idxBlk}.Connection(idxPort), AcBlock.Port)&& isfield(sys.Blocks{idxBlk}.OutputGroup, 'f'))
            
            len = length(sys.Blocks{idxBlk}.OutputGroup.f)-1;
            
            sys.state.x(idxX:idxX+len)   = sys.state.x(idxX-1)+sys.Blocks{idxBlk}.state.x;
            sys.state.idx(idxX:idxX+len) = sys.state.idx(idxX-1)+sys.Blocks{idxBlk}.state.idx;
            sys.state.rho(idxX:idxX+len) = sys.Blocks{idxBlk}.state.rho;
            sys.state.c(idxX:idxX+len)   = sys.Blocks{idxBlk}.state.c;
            sys.state.Mach(idxX:idxX+len)= sys.Blocks{idxBlk}.state.Mach;
            sys.state.A(idxX:idxX+len)   = sys.Blocks{idxBlk}.state.A;
            
            idxX = idxX+len+1;
        end
    end
end

if size(x0,1)==sys.n
    sys.x0 = x0;
elseif ~isempty(x0) && ~all(x0==0)
   warning('Updating changed the order of the system, initial vector is  reinitialized to zero');
end
sys.uptodate = true;
end