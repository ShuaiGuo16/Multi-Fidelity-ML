function plotPoleMap(varargin)
% Plot interactive pole map. Matlab data tips plots the eigenmode.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate
% thermoacoustic network systems. It is developed by the
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% plotPoleMap(sys1,sys2,...)
% Input:        * sys: thermoacoustic network (tax) model object
%
% ------------------------------------------------------------------
% Authors:      Stefan Jaensch (jaensch@tfd.mw.tum.de)
% Last Change:  14 Oct 2015
% ------------------------------------------------------------------

figure('name','Eigenvalues limited by MinGrowthMaxfreq in [Hz]')
hold all;
for  i = 1:length(varargin);
    sys = varargin{i};
    
    [result.V, D, result.W] = eig(sys);
    D = diag(D);
    result.D = D;
    
    plot(real(result.D)/(2*pi), imag(result.D)/(2*pi),'x','DisplayName',sys.Name)
        
end
line([0 0],[-1,1] * sys.fMax,'Color','black','LineStyle','--');
line([-1,1] * sys.fMax,[0 0],'Color','black','LineStyle','--');
hold off;
ylim([0, sys.fMax]);xlim([-sys.fMax, max(real(result.D)/(2*pi))]);
xlabel('Growth rate [1/s]')
ylabel('Frequency [Hz]')
box on;
grid on;
dcm_obj = datacursormode(gcf);
dcm_obj.UpdateFcn = @(x,y) Callback_plotEigenMode(x,y,varargin);

end

function output_txt = Callback_plotEigenMode(obj,event_obj,syss)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

isys = find(cellfun(@(x) strcmp(event_obj.Target.DisplayName,x.Name),syss));
sys = syss{isys};
[V, D, ~] = eig(sys);
D = diag(D);


pos = get(event_obj,'Position');
% Create cursor display
output_txt = {['sigma: ',num2str(pos(1),4) ' 1/s'],...
    ['f: ',num2str(pos(2),4) ' Hz'],...
    ['model name: ' event_obj.Target.DisplayName]};

% Determine eigenvector
i = find(full(D)/(2*pi)==pos(1)+1i*pos(2));
C_f = sys.c(sys.OutputGroup.f,:);
C_g = sys.c(sys.OutputGroup.g,:);
f = C_f*V(:,i);
g = C_g*V(:,i);
[AcVec, name, unit] = sys.calcProperty(f, g, sys.property);

% Check if plots already exists
figTag = 'tax_EigenModePlot';
fig = findobj('Tag',figTag);
DisplayName = strjoin(output_txt,', ');
if isempty(fig)
    fig = figure;
    fig.Tag = figTag;
    DisplayNames = {};
else
    DisplayNames = get(fig.Children(1).Children,'DisplayName');
    if length(fig.Children(1).Children)==1
        DisplayNames = {DisplayNames};
    end
end

figure(fig);
% Add plot if necessary
if ~any(cellfun(@(x) strcmp(DisplayName,x),DisplayNames))
    plotEigenMode(fig,sys.state.x,AcVec, name, unit,sys.format,DisplayName)
end

end
function plotEigenMode(fig,x,AcVec, name, unit,format,DisplayName)
% plot eigenmode
XLabel = 'x [m]';
set(fig.Children,'NextPlot','add')
plotOpts = {'DisplayName',DisplayName};
switch format
    case 'realImag'
        k = 1;
        for i = 1:2;
            subplot(2,2,k)
            plot(x,real(AcVec{i}),plotOpts{:});
            ylabel(['Re(',name{i},') ', unit{i}]);
            xlabel(XLabel);
            
            subplot(2,2,k+1)
            plot(x, imag(AcVec{i}),plotOpts{:});
            ylabel(['Im(',name{i},') ', unit{i}])
            xlabel(XLabel);
            
            k = k+2;
        end
        
    case 'absPhase'
        k = 1;
        for i = 1:2;
            subplot(2,2,k)
            plot(x,abs(AcVec{i}),plotOpts{:});
            ylabel(['|',name{i},'| ',unit{i}]);
            xlabel(XLabel);
            
            subplot(2,2,k+2)
            plot(x, angle(AcVec{i}),plotOpts{:});
            ylabel(['\angle',name{i},' [rad]'])
            xlabel(XLabel);
            
            k = k+1;
        end
end
set(fig.Children,'NextPlot','replace')
set(fig.Children,'Box','on')
set(fig.Children,'XGrid','on')
set(fig.Children,'YGrid','on')
set(fig.Children,'XLim',x([1,end]))
end
