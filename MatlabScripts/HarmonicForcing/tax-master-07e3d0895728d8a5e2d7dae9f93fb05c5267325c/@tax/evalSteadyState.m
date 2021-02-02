function [sys] = evalSteadyState(sys)
% evalSteadyState function to resolve the mean state of the entire model
% using the information specified by the user
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% sys = tax(PathToModel);
% Input:        * sys: tax object
% Output:       * sys: tax object with entirely resolved mean values 
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------

BlkList = cellfun(@(x) x.Name, sys.Blocks, 'UniformOutput', false);
finished = false;
maxIter= 100; ii = 0;
%% While not all blocks are uptodate
Blocks = sys.Blocks;
Connections =  sys.Connections;
while(not(finished))
    finished = true;
    %% Iterate over all connections
    for i = 1:size(Connections,1)
        % Determine index of Block
        idxu = find(strcmp(Connections{i,1},BlkList));
        idxd = find(strcmp(Connections{i,3},BlkList));
        % Determine index of port
        portu = Connections{i,2};
        portd = Connections{i,4};
        % Retrieve connection properties of desired Block
        conu = Blocks{idxu}.Connection;
        cond = Blocks{idxd}.Connection;
        % Select connection properties of desired Port
        con{1} = conu{portu};
        con{2} = cond{portd};
        % Solve the interface values
        con = Block.solveMean(con);
        % Save the solved values
        conu{portu} = con{1};
        cond{portd} = con{2};
        
        % Check for completeness before setting connection
        if not(Blocks{idxu}.uptodate)||not(Blocks{idxd}.uptodate)
            finished = false;
        end
        
        % Set connection triggers locally solving for mean values
        Blocks{idxu} = set_Connection(Blocks{idxu}, conu);
        Blocks{idxd} = set_Connection(Blocks{idxd}, cond);
    end
    
    % Limit number of iterations
    if ii<maxIter
        ii = ii+1;
    else
        error(['Mean Calculations did not finish after ',num2str(maxIter), 'Iterations'])
    end
end

sys.Blocks = Blocks;