classdef simpleDuct < AcBlock & ss
    % simpleDuct simple acoustic model of a duct.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % sys = simpleDuct(pars);
    % Input:   * pars.Name: string of name of the chokedExit
    %          * pars.l:    length of duct
    %          * pars.fMax: maximum frequency to be resolved by duct
    % optional * pars.(...): see link to AcBlock.Port definitions below to
    %          specify mean values and port properties in constructor
    % Output:  * sys: simpleDuct object
    %
    % sys = simpleDuct(Duct);
    % Input:   * Duct: Duct model
    % Output:  * simpleDuct: analytic time delay duct model
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % See also: AcBlock.Port, AcBlock, Block, Duct
    
    properties
        l,fMax, StateGroup,n;
    end
    
    methods
        function sys = simpleDuct(pars)
            % Call empty constructors with correct in and output dimension
            % and port number
            sys@AcBlock(AcBlock.Port,AcBlock.Port);
            sys@ss(zeros(2,2));
            
            sys.fMax = pars.fMax;
            sys.Name = pars.Name;
            
            if iscell(pars.l)
                sys.l = eval(cell2mat(pars.l));
            else
                sys.l = pars.l;
            end
            
            % Copy Connection from Duct to simpleDuct
            if isa(pars, 'Duct')
                sys = set_Connection(sys, pars.Connection);
            end
            
            con = Block.readPort(pars,sys.Connection);
            sys = set_Connection(sys, con);
        end
        
        %% Set functions
        function sys = set.l(sys, l)
            if not(isequal(sys.l, l))
                sys.l = l;
                sys.uptodate = false;
            end
        end
        function sys = set.fMax(sys, fMax)
            if not(isequal(sys.fMax, fMax))
                sys.fMax = fMax;
                sys.uptodate = false;
            end
        end
        
        %% Get functions
        function n = get.n(sys)
            n = size(sys.D);
        end
        
        %% Mean values on interfaces
        function sys = set_Connection(sys, con)
            sys.Connection = Block.solveMean(con);
            if Block.checkPort(sys.Connection,AcBlock.Port)
                sys = update(sys);
            end
        end
        
        %% Declaration of Abstract functions
        function sys = update(sys)
            %% Check if system is uptodate
            if sys.uptodate
                return
            end
            
            Mach = -sys.Connection{1}.Mach;
            c = sys.Connection{1}.c;
            
            sys.D = fliplr(eye(2));
            sys.InputDelay = [sys.l/(c*(1+Mach));sys.l/(c*(1-Mach))];
            
            % Give names to the ports and create in- and output groups
            sys = twoport(sys);
            
            %% Populate plotting quantities
            sys.state.x = sys.l;
            
            sys.uptodate = true;
        end
    end
end