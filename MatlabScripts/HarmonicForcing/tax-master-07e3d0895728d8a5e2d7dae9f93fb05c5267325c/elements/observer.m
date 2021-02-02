classdef observer < AcBlock & sss
    % OBSERVER observer class to have nice plots of frequency responses.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % sys = observer(pars);
    % Input:   * pars.Name:  string of name of the chokedExit
    %          * pars.property: f_g, p_u, impedance_admittance, intensity
    %                           property to be observered
    % optional * pars.(...): see link to AcBlock.Port definitions below to
    %          specify mean values and port properties in constructor
    % Output:  * sys: observer object
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % See also: AcBlock.Port, AcBlock, Block
    
    properties
        property
    end
    
    methods
        function sys = observer(pars)
            % Call constructor with correct number of ports and port type
            sys@AcBlock(AcBlock.Port,AcBlock.Port);
            % Call constructor with correct in and output dimension
            sys@sss(zeros(2,2));
            
            %% Create Block from Simulink getmodel()
            sys.Name = pars.Name;
            if iscell(pars.property)
                %% Create Block from Simulink getmodel()
                %% Load model
                sys.property = char(pars.property);
            else
                sys.property = pars.property;
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
            
            switch sys.property
                case 'p_u'
                    sys.D = [fliplr(eye(2)); 1*(sys.state.rho*sys.state.c), 1*(sys.state.rho*sys.state.c); 1, -1];
                    sys.y{3} = [sys.Name,'_p'];
                    sys.y{4} = [sys.Name,'_u'];
                case 'f_g'
                    sys.D = [fliplr(eye(2)); 1, 0; 0, 1];
                    sys.y{3} = [sys.Name,'_f'];
                    sys.y{4} = [sys.Name,'_g'];
            end
            
            sys = twoport(sys);
            sys.OutputGroup.Observer = 3:4;
            
            sys.uptodate = true;
        end
    end
end