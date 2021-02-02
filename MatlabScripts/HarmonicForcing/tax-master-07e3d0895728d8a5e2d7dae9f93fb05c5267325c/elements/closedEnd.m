classdef closedEnd < AcBlock & sss
    % CLOSEDEND closed end class.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % sys = closedEnd(pars);
    % Input:   * pars.Name:  string of name of the chokedExit
    % optional * pars.(...): see link to AcBlock.Port definitions below to
    %          specify mean values and port properties in constructor
    % Output:  * sys: closedEnd object
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % See also: AcBlock.Port, AcBlock, Block
    
    methods
        function sys = closedEnd(pars)
            % Call empty constructor with correct in and output dimension
            % and port number
            sys@AcBlock(AcBlock.Port);
            sys@sss(zeros(1,1));
            
            %% Create Block from Simulink getmodel()
            sys.Name = pars.Name;
            
            con = Block.readPort(pars,sys.Connection);
            sys = set_Connection(sys, con);
        end
        
        %% Mean values on interfaces
        function sys = set_Connection(sys, con)
            sys.Connection = con(1);
            if Block.checkPort(con(1),AcBlock.Port)
                sys = update(sys);
            end
        end
        
        %% Generate system
        function [sys] = update(sys)
            if sys.uptodate
                return
            end
            Mach = sys.Connection{1}.Mach;
            
            % Mach Number has a sign, by which it covers up and downstream ends
            sys.D = -(Mach-1)/(Mach+1);
            
            sys= oneport(sys);
            
            sys.uptodate = true;
        end
    end
end