classdef reflEnd < AcBlock & sss
    % REFLEND reflective end class.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % sys = reflEnd(pars);
    % Input:   * pars.Name:  string of name of the chokedExit
    %          * pars.r:     reflection factor: transfer function
    %          expression r(s) = (a0+a1*s+a2s^2+...)/(b0+b1*s+b2s^2+...)
    % optional * pars.(...): see link to AcBlock.Port definitions below to
    %          specify mean values and port properties in constructor
    % Output:  * sys: reflEnd object
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % See also: AcBlock.Port, AcBlock, Block
    properties
        r
    end
        
    methods
        function sys = reflEnd(pars)
            % Call constructor with correct number of ports and port type
            sys@AcBlock(AcBlock.Port);
            % Call constructor with correct in and output dimension
            sys@sss(zeros(1,1));
            
            sys.Name = pars.Name;
            
            % Read in transfer function for reflections
            s = tf('s'); %#ok<NASGU>
            if iscell(pars.r)
                r = cell2mat(pars.r);
                r = strrep(r,'''','');
                sys.r = eval(r);
            else
                sys.r = pars.r;
            end
            con = Block.readPort(pars,sys.Connection);
            sys = set_Connection(sys, con);
        end
        
        %% Set functions
        function sys = set.r(sys, r)
            if not(isequal(sys.r, r))
                sys.r = r;
                sys.uptodate = false;
            end
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
            
            sys = updatesss(sys,ss([sys.r,1]));
            
            sys= oneport(sys);
            sys.InputName(2) = {sys.Name};
            sys.InputGroup.loudSpeaker = 2;
            
            sys.uptodate = true;
        end
    end
end