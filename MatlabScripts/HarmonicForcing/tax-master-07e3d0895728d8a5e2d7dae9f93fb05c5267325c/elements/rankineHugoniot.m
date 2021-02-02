classdef rankineHugoniot < AcBlock & sss
    % rankineHugoniot class describing a temperature jump across a flat
    % flame considering heat release fluctuations.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % sys = rankineHugoniot(pars);
    % Input:   * pars.Name:  string of name of the chokedExit
    %          * pars.nRef: number of flame reference inputs/ heat release
    %          contributions
    %          * pars.Mach: downstream Mach number
    %          * pars.rho:  downstream density
    %          * pars.c:    downstream speed of sound
    % Output:  * sys: rankineHugoniot object
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % See also: AcBlock.Port, AcBlock, Block
    
    methods
        function sys = rankineHugoniot(pars)
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
            
            %% Create Block from Simulink getmodel()
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
            conac = con([1,end]);
            conacd =conac{2};
            confl = con(2:end-1);
            
            conac{2} = rmfield(conac{2},{'Mach','rho','c'});
            
            %% Solve for mean
            conac = Block.solveMean(conac);
            %% Patch in values past flame
            conac{2}.Mach = conacd.Mach;conac{2}.rho = conacd.rho;conac{2}.c = conacd.c;
            
            con ={conac{1},confl{1:end},conac{2}}; 
            
            checkFlame = true;
            for i = 1: size(confl)
                if not(isfield(sys.Connection{1+i},'FlameName'))
                    checkFlame = false;
                end
            end
            
            sys.Connection = con;
            if Block.checkPort(conac,AcBlock.Port)&&(checkFlame)
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
            
            M_d = sys.Connection{end}.Mach;
            c_d = sys.Connection{end}.c;
            rho_d = sys.Connection{end}.rho;
            
            %%% Vorsicht: das muss noch raus und in connection übergeben werden!
            gamma = 1.4;
            
            tempRatio = (c_d/c_u)^2;
            %%%%
            
            % prefactor = 1/( (rho_u*c_u)/(rho_d*c_d) + (T_d/T_u-1)*M_d + gamma*(T_d/T_u-1)*M_u + 1 );
            Denomminator = 1/( (rho_u*c_u)/(rho_d*c_d) + (tempRatio-1)*M_d + gamma*(tempRatio-1)*M_u + 1 );
            
            A(1,1) = -(rho_u*c_u)/(rho_d*c_d) + (tempRatio-1)*M_d - gamma*(tempRatio-1)*M_u + 1;
            A(1,2) = 2;
            A(2,1) = 2*( (rho_u*c_u)/(rho_d*c_d) - (tempRatio-1)^2*gamma*M_u*M_d ) ;
            A(2,2) = (rho_u*c_u)/(rho_d*c_d) + (tempRatio-1)*M_d - gamma*(tempRatio-1)*M_u - 1;
            
            % Heat release endogenous excitation
            
            A(1,3) = M_d + 1;
            % localMatrix(1,3) = localMatrix(1,3)*u_u/u_u*(tempRatio-1);
            
            A(2,3) = - M_d*( gamma*(tempRatio-1)*M_u +1 ) + ((rho_u*c_u)/(rho_d*c_d) + (tempRatio-1)*M_d) ;
            A(:,3) = A(:,3)*u_u*(tempRatio-1);
            
            A = Denomminator*A;
            
            sys.D = A;
            sys = twoport(sys,[1,3]);
            
            confl = sys.Connection(2:end-1);
            nFlames = size(confl,2);
            
            FlameNames = cellfun(@(x) x.FlameName, confl, 'UniformOutput', false);
            
            Qp = sss(ones(1,nFlames));
            Qp.u = FlameNames(:);
            Qp.y = {sys.Name};
            Qp.InputGroup.Flame = 1:nFlames;
            
            sys.u{3} = sys.Name;
            sys = connect(sys,Qp,[sys.u([1,2]);Qp.u],sys.y);
            
            sys.uptodate = true;
        end
    end
end