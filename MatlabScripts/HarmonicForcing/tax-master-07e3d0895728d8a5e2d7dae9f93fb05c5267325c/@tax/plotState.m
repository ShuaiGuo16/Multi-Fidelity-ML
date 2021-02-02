function [axi] = plotState(sys,x_state,t,axi)
%plotState: This function visualizes the pressure and velocity distribution
%             of a tax system   
%------------------------------------------------------------------
% Syntax:
%               axi = plotState(sys,x_state,t,axi)
%               plotState(sys,x_state)
%
% Inputs:    
%
%               *Required Input Arguments:*
%
%               * x_state:   current state vector of system to be visualized
%               * sys:       on sss-object containing the LTI-system
%               
%               *Optional Input Arguments:*
%
%               * t:         time instance matching with the state vector
%               * axi:       2x4 matrix containing axis vectors in each row
%                            for p-x plot: axi(1,:) = [xmin xmax ymin ymax]
%                            for u-x plot: axi(2,:) = [xmin xmax ymin ymax]
%
% Output:
%
%               *Optinal Output Argument:*
%
%               * axi:       updated 2x4 matrix containing axis vectors in
%                            each row, where axis can only increase
%               
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

if (nargin == 2 && nargout == 0)
    t = '-';
    axi = zeros(2,4);
end

C_f = sys.C(sys.OutputGroup.f,:);
C_g = sys.C(sys.OutputGroup.g,:);
 

f = C_f*x_state;
g = C_g*x_state;

[AcVec, name, unit] = sys.calcProperty(f,g, sys.property);

% adapting axis such that domain represented by y-axis does not decrease
 if axi(:,[1 2]) == zeros(2,2)
        axi(:,[1 2]) = ones(2,1)*[min(sys.state.x) max(sys.state.x)];
 end
        axi(1,3) = min(min(AcVec{1}),axi(1,3));
        axi(1,4) = max(max(AcVec{1}),axi(1,4));
        axi(2,3) = min(min(AcVec{2}),axi(2,3));
        axi(2,4) = max(max(AcVec{2}),axi(2,4));
        
        
 %% visualisation of p-x and u-x distribution
            subplot(2,1,1)
            plot(sys.state.x,AcVec{1});
            title(['Pressure distribution at time: ',num2str(t),'s']);
            grid on;
            ylabel((['Re(',name{1},') ', unit{1}]));
            xlabel('Location in model [m]');
            if(axi(1,4)> axi(1,3))
                axis(axi(1,:));
            end
    
            subplot(2,1,2);
            plot(sys.state.x,AcVec{2});
            title(['Velocity distribution at time: ',num2str(t),'s']);
            grid on;
            ylabel((['Im(',name{2},') ', unit{2}]));
            xlabel('Location in model [m]');
            if(axi(2,4)> axi(2,3))
                 axis(axi(2,:));
            end
          drawnow;
end

