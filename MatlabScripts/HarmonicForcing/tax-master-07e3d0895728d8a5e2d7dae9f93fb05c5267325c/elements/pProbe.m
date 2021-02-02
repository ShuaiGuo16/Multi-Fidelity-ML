classdef pProbe <  AcBlock & sss
    % PPROBE is a pressure probe. Usage: connect to system, using all
    % input and output names.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % sys = pProbe(pars);
    % Input:   * pars.Name:  string of name of the chokedExit
    %          * pars.pLabel: label of pressure measurement output
    %          * pars.flabel: label of f-wave to be observed
    %          * pars.glabel: label of g-wave to be observed
    %          * pars.rho:    density
    %          * pars.c:      speed of sound
    % Output:  * sys: pProbe object
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % See also: AcBlock.Port, AcBlock, Block
    
    methods
        function sys = pProbe(pLabel, flabel, glabel, rho, c)
            
            sys@sss([1/(rho*c), 1/(rho*c)]);
            sys.Name = pLabel;
            sys.y = pLabel;
            sys.u = [flabel; glabel];
            sys.uptodate = false;
        end
        function sys = update(sys)
            sys.uptodate = true;
        end
    end
end