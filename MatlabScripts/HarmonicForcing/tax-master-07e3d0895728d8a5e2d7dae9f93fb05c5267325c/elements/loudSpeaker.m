classdef loudSpeaker < AcBlock & sss
    % LOUDSPEAKER class for calculating inhomogeneous solutions of the
    % network model.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % sys = loudSpeaker(pars);
    % Input:   * pars.Name:  string of name of the chokedExit
    %          * pars.Amp:   amplification/gain of loudspeaker input
    % optional * pars.(...): see link to AcBlock.Port definitions below to
    %          specify mean values and port properties in constructor
    % Output:  * sys: loudSpeaker object
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % See also: AcBlock.Port, AcBlock, Block
    
    properties(SetAccess = private)
        % amplification/gain of loudspeaker input
        Amp
    end
    
    methods
        function sys = loudSpeaker(pars)
            % Call empty constructors with correct in and output dimension
            % and port number
            sys@AcBlock(AcBlock.Port);
            sys@sss(zeros(1,2));
            
            sys.Amp=1;
            
                %% Create Block from Simulink getmodel()
                sys.Amp = eval(cell2mat(pars.Amp));
                sys.Name = pars.Name;
                
                con = Block.readPort(pars,sys.Connection);
            
            sys = set_Connection(sys, con);
        end
        
        function sys = set.Amp(sys,Amp)
            if not(isequal(sys.Amp, Amp))
                sys.Amp = Amp;
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
        function sys = update(sys)
            if sys.uptodate
                return
            end
            sys.D = [1, sys.Amp];
            sys = oneport(sys);
            
            sys.InputName(2) = {sys.Name};
            sys.InputGroup.loudSpeaker = 2;
            
            sys.uptodate = true;
        end
    end
end