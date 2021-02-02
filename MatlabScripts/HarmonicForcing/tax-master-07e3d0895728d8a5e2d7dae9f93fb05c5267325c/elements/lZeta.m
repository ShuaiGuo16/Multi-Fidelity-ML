classdef lZeta < AcBlock & sss
    % LZETA area jump class with effective and reduced length and loss
    % coefficient.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % sys = lZeta(pars);
    % Input:   * pars.Name: string of name of the chokedExit
    %          * pars.A:    double vector of areas [A_upstream, A_downstream]
    % optional * pars.zeta: double loss coefficient
    %          * pars.lred: double reduced length
    %          * pars.leff: double effective length
    %          * pars.(...): see link to AcBlock.Port definitions below to
    %          specify mean values and port properties in constructor
    % Output:  * sys: lZeta object
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % See also: AcBlock.Port, AcBlock, Block
    
    properties
        zeta,lred,leff
    end
    
    methods
        function sys = lZeta(pars)
            % Call constructor with correct number of ports and port type
            sys@AcBlock(AcBlock.Port,AcBlock.Port);
            % Call constructor with correct in and output dimension
            sys@sss(zeros(2,2));
            
            %% Create Block from Simulink getmodel()
            sys.Name = pars.Name;
            
            if isfield(pars,'zeta')
                if iscell(pars.zeta)
                    sys.zeta = eval(cell2mat(pars.zeta));
                else
                    sys.zeta = pars.zeta;
                end
            else
                sys.zeta = 0;
            end
            if isfield(pars,'lred')
                if iscell(pars.lred)
                    sys.lred = eval(cell2mat(pars.lred));
                else
                    sys.lred = pars.lred;
                end
            else
                sys.lred = 0;
            end
            if isfield(pars,'leff')
                if iscell(pars.leff)
                    sys.leff = eval(cell2mat(pars.leff));
                else
                    sys.leff = pars.leff;
                end
            else
                sys.leff = 0;
            end
            
            con = sys.Connection;
            if iscell(pars.A)
                con{2}.A = eval(cell2mat(pars.A));
            else
                con = Block.readPort(pars,sys.Connection);
            end
            sys.Connection = con;
        end
        
        %% Mean values on interfaces
        function sys = set_Connection(sys, con)
            %% Remove Mach and A then solve mean.
            if (Block.checkField(con{1},'A')&&Block.checkField(con{2},'A')) && (Block.checkField(con{1},'Mach')||Block.checkField(con{2},'Mach'))
                A(1) = con{1}.A;
                con{1} = rmfield(con{1},'A');
                A(2) = con{2}.A;
                con{2} = rmfield(con{2},'A');
                if Block.checkField(con{1},'Mach')
                    Mach(1) = con{1}.Mach;
                    con{1} = rmfield(con{1},'Mach');
                    Mach(2) = -A(1)/A(2)*Mach(1);
                end
                if Block.checkField(con{2},'Mach')
                    Mach(2) = con{2}.Mach;
                    con{2} = rmfield(con{2},'Mach');
                    Mach(1) = -A(2)/A(1)*Mach(2);
                end
                
                con = Block.solveMean(con);
                
                %% Then solve massbalance and append
                con{1}.A = A(1);
                con{2}.A = A(2);
                con{1}.Mach = Mach(1);
                con{2}.Mach = Mach(2);
                
                sys.Connection = con;
            end
            
            if Block.checkPort(con,AcBlock.Port)
                sys = update(sys);
            end
        end
        %% Set functions
        function sys = set.zeta(sys, zeta)
            if not(isequal(sys.zeta, zeta))
                sys.zeta = zeta;
                sys.uptodate = false;
            end
        end
        function sys = set.lred(sys, lred)
            if not(isequal(sys.lred, lred))
                sys.lred = lred;
                sys.uptodate = false;
            end
        end
        function sys = set.leff(sys, leff)
            if not(isequal(sys.leff, leff))
                sys.leff = leff;
                sys.uptodate = false;
            end
        end
        
        
        %% Generate system
        function [sys] = update(sys)
            % LZETA area jump with pressure loss coefficient zeta and reduced length
            % lred and effective length leff
            %
            % (c) Copyright 2010 tdTUM. All Rights Reserved.
            if sys.uptodate
                return
            end
            Machi = sys.Connection{1}.Mach;
            
            ai = sys.Connection{1}.A;
            c = sys.Connection{1}.c;
            % rho = Connection{1}.rho;
            Machj = sys.Connection{2}.Mach;
            
            aj = sys.Connection{2}.A;
            
            zeta = sys.zeta;
            lred = sys.lred;
            leff = sys.leff;
            
            % Possible automatic calculation/approximation of reduced length: (?)
            % l is the reduced length (according to Schuermans & Polifke "Modeling
            % Transfer Matrices of Premixed Flames and Comparison with Experimental
            % Results"
            % The equation for l is:
            % l = integral(A1/A(x) *dx) evaluated from point 1 to point 2
            % An approximate value for this is 3/4*l
            % lred = 0.75*Block.l;
            
            % Possible automatic calculation/approximation of pressure loss: (?)
            % zeta = (1 - (aj/ai))^2 ;
            % if (ai/aj) > 1
            %   zeta = 1.25*zeta*(0.2+ (ai/aj));
            % end
            
            % Matrix is obtained by symbolic solving for the scattering matrix, see
            % documentation and lZeta_symbolic.m
            s = tf('s');
            
            % Original taX formulation (equivalent to ta2):
            % D(1,:) = [ -(Machi*ai*c - Machj*aj*c + ai*c*kappa_pi - aj*c*kappa_pj + Machi*Machj*ai*c*kappa_pj - Machi*Machj*aj*c*kappa_pi + Machj*ai*c*kappa_pi*kappa_pj - Machi*aj*c*kappa_pi*kappa_pj + Machj*aj*kappa_pi*lred*s + aj*kappa_pi*kappa_pj*lred*s + Machi*Machj*ai*c*kappa_pj*zeta + Machj*ai*c*kappa_pi*kappa_pj*zeta)/(Machi*ai*c - Machj*aj*c + ai*c*kappa_mi - aj*c*kappa_pj + Machi*Machj*ai*c*kappa_pj - Machi*Machj*aj*c*kappa_mi + Machj*ai*c*kappa_mi*kappa_pj - Machi*aj*c*kappa_mi*kappa_pj + Machj*aj*kappa_mi*lred*s + aj*kappa_mi*kappa_pj*lred*s + Machi*Machj*ai*c*kappa_pj*zeta + Machj*ai*c*kappa_mi*kappa_pj*zeta),                                                                                                                                                                                                                                               -(aj*c*(kappa_mj - kappa_pj)*(Machj^2*zeta + Machj^2 - 1))/(Machi*ai*c - Machj*aj*c + ai*c*kappa_mi - aj*c*kappa_pj + Machi*Machj*ai*c*kappa_pj - Machi*Machj*aj*c*kappa_mi + Machj*ai*c*kappa_mi*kappa_pj - Machi*aj*c*kappa_mi*kappa_pj + Machj*aj*kappa_mi*lred*s + aj*kappa_mi*kappa_pj*lred*s + Machi*Machj*ai*c*kappa_pj*zeta + Machj*ai*c*kappa_mi*kappa_pj*zeta)];
            % D(2,:) = [                                                                                                                                                                                                                                                 (ai*(kappa_mi - kappa_pi)*(- c*Machi^2 + lred*s*Machi + c))/(Machi*ai*c - Machj*aj*c + ai*c*kappa_mi - aj*c*kappa_pj + Machi*Machj*ai*c*kappa_pj - Machi*Machj*aj*c*kappa_mi + Machj*ai*c*kappa_mi*kappa_pj - Machi*aj*c*kappa_mi*kappa_pj + Machj*aj*kappa_mi*lred*s + aj*kappa_mi*kappa_pj*lred*s + Machi*Machj*ai*c*kappa_pj*zeta + Machj*ai*c*kappa_mi*kappa_pj*zeta), -(Machi*ai*c - Machj*aj*c + ai*c*kappa_mi - aj*c*kappa_mj + Machi*Machj*ai*c*kappa_mj - Machi*Machj*aj*c*kappa_mi + Machj*ai*c*kappa_mi*kappa_mj - Machi*aj*c*kappa_mi*kappa_mj + Machj*aj*kappa_mi*lred*s + aj*kappa_mi*kappa_mj*lred*s + Machi*Machj*ai*c*kappa_mj*zeta + Machj*ai*c*kappa_mi*kappa_mj*zeta)/(Machi*ai*c - Machj*aj*c + ai*c*kappa_mi - aj*c*kappa_pj + Machi*Machj*ai*c*kappa_pj - Machi*Machj*aj*c*kappa_mi + Machj*ai*c*kappa_mi*kappa_pj - Machi*aj*c*kappa_mi*kappa_pj + Machj*aj*kappa_mi*lred*s + aj*kappa_mi*kappa_pj*lred*s + Machi*Machj*ai*c*kappa_pj*zeta + Machj*ai*c*kappa_mi*kappa_pj*zeta)];
            
            % Polifke simplification polif11a
            % T = [1         , s*leff/c - zeta*Machi;...
            %      -s*lred/c , ai/aj                ];
            % hardcoded solution:
            % D(1,:) = [                                                 1 - (2*Machj + (2*lred*s)/c + 2)/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1),                                        2/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1)];
            % D(2,:) = [ ((2*ai)/aj - 2*(Machj + (lred*s)/c)*(Machi*(zeta + ai^2/aj^2 - 1) + (leff*s)/c))/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1), 1 - (2*Machj + (2*ai)/aj + (2*lred*s)/c)/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1)];
            
            % Gentemann & Polifke 2003 Definition:
            % T= [1, (1-zeta-(ai/aj)^2)*Machi - s*leff/c; ...
            %     -s*lred/c - Machj,  ai/aj];
            % hardcoded solution:
            tf_sys(1,:) = [                                                 1 - (2*Machj + (2*lred*s)/c + 2)/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1),                                        2/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1)];
            tf_sys(2,:) = [ ((2*ai)/aj - 2*(Machj + (lred*s)/c)*(Machi*(zeta + ai^2/aj^2 - 1) + (leff*s)/c))/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1), 1 - (2*Machj + (2*ai)/aj + (2*lred*s)/c)/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1)];
            
            % Transformation to scattering matrix
            % sys = transformTtoS(T);
            
            ss_sys = ss(tf_sys);
            
            sys.A = ss_sys.A;sys.B = ss_sys.B; sys.C = ss_sys.C; sys.D = ss_sys.D; sys.E = ss_sys.E;
            
            sys = twoport(sys);
            
            sys.uptodate = true;
        end
    end
end