classdef scatteringDummy < AcBlock & sss
    % DUCT dummy element for scattering matrix computations.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % sys = scatteringDummy(pars);
    % Input:   * pars.Name:  string of name of the chokedExit
    %          * pars.loc: 'Upstream' or 'Downstream', location of block
    %          with respect to the internal part of the scattering system 
    % optional * pars.(...): see link to AcBlock.Port definitions below to
    %          specify mean values and port properties in constructor
    % Output:  * sys: scatteringDummy object
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % See also: AcBlock.Port, AcBlock, Block
    
    properties
        % 'Upstream' or 'Downstream', location of block with respect to the
        %  internal part of the scattering system
        loc
    end
    
    methods
        function sys = scatteringDummy(pars)
            % Call constructor with correct number of ports and port type
            sys@AcBlock(AcBlock.Port,AcBlock.Port);
            % Call constructor with correct in and output dimension
            sys@sss(zeros(2,2));
            
            sys.Name = pars.Name;
            if iscell(pars.loc)
                sys.loc = char(cell2mat(pars.loc));
            else
                sys.loc = pars.loc;
            end
            
            con = Block.readPort(pars,sys.Connection);
            sys = set_Connection(sys, con);
        end
        
        %% Mean values on interfaces
        function sys = set_Connection(sys, con)
            sys.Connection = Block.solveMean(con);
            if Block.checkPort(con,AcBlock.Port)
                sys = update(sys);
            end
        end
        
        %% Generate system
        function [sys] = update(sys)
            if sys.uptodate
                return
            end
            
            sys.D = fliplr(eye(2));
            sys = twoport(sys);
            
            switch char(sys.loc)
                case 'Upstream'
                    % Flow is directed out of the element
                    sys.OutputGroup.Scatter = 1;
                    sys.InputGroup.Scatter = 1;
                case 'Downstream'
                    % Flow is directed into the element
                    sys.OutputGroup.Scatter = 2;
                    sys.InputGroup.Scatter = 2;
            end
            
            sys.uptodate = true;
        end
    end
end