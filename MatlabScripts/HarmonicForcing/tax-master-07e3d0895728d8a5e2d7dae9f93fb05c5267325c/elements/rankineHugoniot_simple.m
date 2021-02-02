classdef rankineHugoniot_simple < AcBlock & sss
    % rankineHugoniot_simple class describing a temperature jump across a flat
    % flame considering heat release fluctuations neglecting mach number effects.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % sys = rankineHugoniot_simple(pars);
    % Input:   * pars.Name:  string of name of the chokedExit
    %          * pars.nRef: number of flame reference inputs/ heat release
    %          contributions
    %          * pars.Mach: downstream Mach number
    %          * pars.rho:  downstream density
    %          * pars.c:    downstream speed of sound
    % optional * pars.(...): see link to AcBlock.Port definitions below to
    %          specify mean values and port properties in constructor
    % Output:  * sys: observer object
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % See also: AcBlock.Port, AcBlock, Block
    
    methods
        function sys = rankineHugoniot_simple(pars)
            % Determine number of flames
            if (iscell(pars.nRef))
                nFlames = eval(cell2mat(pars.nRef));
            else
                nFlames = pars.nRef;
            end
            FlamePorts = cell(nFlames,1);
            
            % Call constructor with correct number of ports and port type
            sys@AcBlock(AcBlock.Port,FlamePorts{:},AcBlock.Port);
            % Call constructor with correct in and output dimension
            sys@sss(zeros(2,2+nFlames));
            
            sys.Name = pars.Name;
            
            con = sys.Connection;
            idxAcOut = 2+nFlames;
            if iscell(pars.Mach)
                con{idxAcOut}.Mach = eval(cell2mat(pars.Mach));
                con{idxAcOut}.rho = eval(cell2mat(pars.rho));
                con{idxAcOut}.c = eval(cell2mat(pars.c));
            else
                con{idxAcOut}.Mach = pars.Mach;
                con{idxAcOut}.rho = pars.rho;
                con{idxAcOut}.c = pars.c;
            end
            sys.Connection = con;
        end
        
        %% Mean values on interfaces
        function sys = set_Connection(sys, con)
            %% Remove values past flame
            conac = con([1,3]);
            conacd =conac{2};
            confl = con(2);
            
            conac{2} = rmfield(conac{2},{'Mach','rho','c'});
            
            %% Solve for mean
            conac = Block.solveMean(conac);
            %% Patch in values past flame
            conac{2}.Mach = conacd.Mach;conac{2}.rho = conacd.rho;conac{2}.c = conacd.c;
            
            con ={conac{1},confl{1},conac{2}}; 
            
            sys.Connection = con;
            if Block.checkPort(conac,AcBlock.Port)&&(isfield(sys.Connection{2},'FlameName'))
                sys = update(sys);
            end
        end
        
        %% Generate system
        function [sys] = update(sys)
            if sys.uptodate
                return
            end
            
            M_u = sys.Connection{1}.Mach;
            c_u = sys.Connection{1}.c;
            rho_u = sys.Connection{1}.rho;
            u_u = M_u*c_u;
            A = sys.Connection{1}.A;
            
            M_d = sys.Connection{3}.Mach;
            c_d = sys.Connection{3}.c;
            rho_d = sys.Connection{3}.rho;
            
            tempRatio = (c_d/c_u)^2;
            
            xi = (rho_u*c_u)/(rho_d*c_d);
            theta = tempRatio-1;
            
            Denomminator = 1/( xi + 1 );
            
            A = [ 1 - xi,   2   , 1 ; ...
                  2*xi  , xi - 1, xi];
            
            A(:,3) = theta* A(:,3)* u_u;
            A = Denomminator*A;
            
            sys.D = A;
            sys = twoport(sys,[1,3]);
            sys.u{3} = sys.Connection{2}.FlameName;
            sys.InputGroup.Flame = 3;
            
            sys.uptodate = true;
        end
    end
end