function [ ] = stateVideo(sys,u,t,Ts_sample,method)
% stateVideo generates simulation of pressure and velocity distribution of
% a tax system
% ------------------------------------------------------------------
% Inputs:
%              *Required Input Arguments:*
%
%               * sys:       sss-object containing the LTI system
%               * u:         input signal of the sss-system
%               * t:         time vector, containing every discrete time
%                            instance of the sss-system
%
%               *Optional Input Arguments:*
%
%               * Ts_sample: time step of simulation
%               * method:    time ingetration method (available are:
%                            'forwardEuler', 'backwardEuler', 'RK4', and
%                            'discrete' default: continues 'RK4')
%
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate
% thermoacoustic network systems. It is developed by the
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% Authors:      Michael Leipold, Stefan Jaensch (jaensch@tfd.mw.tum.de)
% Last Change:  17 Dec 2015
% ------------------------------------------------------------------

x = sys.x0;
ti = 0;
i = 1;
axi = zeros(2,4);
% Ts = (max(t)-min(t))/(length(t)-1);
Ts = t(2)-t(1);


if nargin == 3
    Ts_sample = Ts;
    method = 'RK4';
elseif nargin == 4
    method = 'RK4';
end

U = [];
% interpolating u in case Ts_sample lower Ts
if Ts_sample < Ts
    t_fine = min(t):Ts_sample:max(t);
    
    for j = 1:size(u,1)
        uint = interp1(t,u(j,:),t_fine);
        U = [U;uint];
    end
    u = U;
    
    t = t_fine;
    Ts = Ts_sample;
    
else
    m = round(Ts_sample/Ts);
    Ts_sample = m*Ts;
end

% computing the system with lsim function such that X stores only one state
% vector, which will be overwritten after handling it to plotState function
while(i < size(u,1))
    [~,X,~] = lsim(sys,u(i:i+1,:),Ts,method);
    
    if mod(t(i),Ts_sample) == 0
        axi = plotState(sys,X(:,1),ti,axi);
    end
    x = X(:,1);
    ti = ti+Ts;
    i = i+1;
    sys.x0 = x;
end

end
