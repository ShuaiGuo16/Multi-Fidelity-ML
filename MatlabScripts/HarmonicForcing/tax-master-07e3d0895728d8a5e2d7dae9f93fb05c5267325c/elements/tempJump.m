classdef tempJump < AcBlock & sss
    % tempJump 1D temperature jump.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % sys = rankineHugoniot(pars);
    % Input:   * pars.Name:  string of name of the chokedExit
    %          * pars.Mach: downstream Mach number
    %          * pars.rho:  downstream density
    %          * pars.c:    downstream speed of sound
    % Output:  * sys: observer object
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % See also: AcBlock.Port, AcBlock, Block
    
    methods
        function sys = tempJump(pars)
            % Call constructor with correct number of ports and port type
            sys@AcBlock(AcBlock.Port,AcBlock.Port);
            % Call constructor with correct in and output dimension
            sys@sss(zeros(2,2));
            
            %% Create Block from Simulink getmodel()
            sys.Name = pars.Name;
            
            con = sys.Connection;
            if iscell(pars.Mach)
                con{2}.Mach = eval(cell2mat(pars.Mach));
                con{2}.rho = eval(cell2mat(pars.rho));
                con{2}.c = eval(cell2mat(pars.c));
            else
                con{2}.Mach = pars.Mach;
                con{2}.rho = pars.rho;
                con{2}.c = pars.c;
            end
            
            sys.Connection = con;
        end
        
        
        %% Mean values on interfaces
        function sys = set_Connection(sys, con)
            %% Remove values past flame
            cond =con{2};
            
            con{2} = rmfield(con{2},{'Mach','rho','c'});
            
            %% Solve for mean
            con = Block.solveMean(con);
            %% Patch in values past flame
            con{2}.Mach = cond.Mach;con{2}.rho = cond.rho;con{2}.c = cond.c;
            
            sys.Connection = con;
            if Block.checkPort(con,AcBlock.Port)
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
            
            M_d = sys.Connection{2}.Mach;
            c_d = sys.Connection{2}.c;
            rho_d = sys.Connection{2}.rho;
            
            %%% Vorsicht: das muss noch raus und in connection übergeben werden!
            gamma = 1.4;
            
            tempRatio = (c_d/c_u)^2;
            %%%%
            
            % prefactor = 1/( (rho_u*c_u)/(rho_d*c_d) + (T_d/T_u-1)*M_d + gamma*(T_d/T_u-1)*M_u + 1 );
            Denomminator = 1/( (rho_u*c_u)/(rho_d*c_d) + (tempRatio-1)*M_d + gamma*(tempRatio-1)*M_u + 1 );
            
            D(1,1) = -(rho_u*c_u)/(rho_d*c_d) + (tempRatio-1)*M_d - gamma*(tempRatio-1)*M_u + 1;
            D(1,2) = 2;
            D(2,1) = 2*( (rho_u*c_u)/(rho_d*c_d) - (tempRatio-1)^2*gamma*M_u*M_d ) ;
            D(2,2) = (rho_u*c_u)/(rho_d*c_d) + (tempRatio-1)*M_d - gamma*(tempRatio-1)*M_u - 1;
            
            D = Denomminator*D;
            
            sys.D = D;
            sys = twoport(sys);
            
            sys.uptodate = true;
        end
    end
end