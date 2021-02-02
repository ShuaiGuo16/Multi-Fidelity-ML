function sys = adaptTsAndDelays(varargin)
% adaptTsAndDelays function to adapt sampling time, convert identified
% models and eliminate delays.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% sys = adaptTsAndDelays(sys,Ts);
% Input:        * sys: ss,idtf,idss,idpoly,... object
%               * Ts:  desired sampling time
% Output:       * sys: sss object without time delays and sampling time Ts
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------
sys = varargin{1};
Ts = varargin{2};


% Convert idpoly models to state space and keep noise inputs
if (isa(sys,'idpoly')||isa(sys,'idtf'))
    sys = ss(sys,'augmented');
end

if (isa(sys,'tf'))
    sys = ss(sys);
end

if Ts == 0 % If the user wants a continuous system
    %% Transform to continous time
    if sys.Ts > 0 % Discrete system
        sys = d2c(ss(sys),'tustin');
    end
    
    %% Approximate Delays
    try
        intdel = max(get(sys, 'InputDelay'));
    catch err
        %             rethrow(err);
        intdel=0;
    end
    try
        outdel = max(get(sys, 'OutputDelay'));
    catch err
        %             rethrow(err);
        outdel=0;
    end
    try
        indel = max(get(sys, 'InputDelay'));
    catch err
        %             rethrow(err);
        indel=0;
    end
    
    maxIntDelay = max([indel,outdel,intdel]);
    if maxIntDelay>0
        if isprop(sys,'fMax')
            fMax = sys.fMax;
        else
            fMax = varargin{3};
        end
        nPade = round(fMax*maxIntDelay*5);
        if nPade > 10
            warning(['Pade approximation of internal delay of some Block exceeds 10: nPade = ', num2str(nPade)])
        end
        if nPade>50
            nPade=50;
        end
        sys = pade(ss(sys),nPade);
    end
else % The user wants a discrete time system
    if sys.Ts == 0 % Continous system
        sys = c2d(sys,Ts,'tustin');
    elseif sys.Ts ~= Ts % Discrete system at different sampling time
        if sys.Ts > Ts
            disp('This Block is upsampled during conversion to Ts!');
        end
        sys = d2d(sys,Ts,'tustin');
    end
end

% Convert to sparse state space
if (not(isa(sys,'sss')))
    sys = sss(sys);
end

end