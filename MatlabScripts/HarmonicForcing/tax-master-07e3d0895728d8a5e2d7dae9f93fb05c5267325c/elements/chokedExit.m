classdef chokedExit < AcBlock & sss
    % CHOKEDEXIT choked exit end class.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % sys = chokedExit(pars);
    % Input:   * pars.Name:  string of name of the chokedExit
    %          * pars.Gamma: double
    % optional * pars.(...): see link to AcBlock.Port definitions below to
    %          specify mean values and port properties in constructor
    % Output:  * sys: chokedExit object
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % See also: AcBlock.Port, AcBlock, Block
    
    properties
        Gamma
    end
    
    methods
        function sys = chokedExit(pars)
            % Call constructor with correct number of ports and port type
            sys@AcBlock(AcBlock.Port);
            % Call constructor with correct in and output dimension
            sys@sss(zeros(1,1));
            
            sys.Name = pars.Name;
            
            if iscell(pars.Gamma)
                sys.Gamma = eval(cell2mat(pars.Gamma));
            else
                sys.Gamma = pars.Gamma;
            end
            
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
            warning('untested Block: chokedExit')
            
            Mach = -sys.Connection{1}.Mach;
            
            sys.D = -(1-(sys.Gamma-1)/2*Mach)./(-1-(sys.Gamma-1)/2*Mach);
            
            sys = oneport(sys);
            
            sys.uptodate = true;
        end
    end
end