function DrawGeometrie(Param,Geometrie,axes)
% Wurde ein axes Objekt mit angegeben?
if strcmp(axes,'new')
    % Erstellet Plot der Geometrie
%     fg = figure;
    fg = figure('Visible','Off');
    axes = subplot(1,1,1);
end

% Aufloesung
n = 30;


% y-Achse
y = linspace(0,Geometrie.R,n);

switch Param.Flammentyp
    case 'V'
        % Winkel in Grad
        alphaDeg = Geometrie.alpha / pi * 180;
        % Flammenfront Funktion
        F = y * cot(Geometrie.alpha) + Geometrie.l;
        F_mirror = F(end:-1:1);
        
        % Plot
        plot(axes,[-1*y(end:-1:1),y],[F_mirror,F],'r','LineWidth',2); hold on;
        title(sprintf('alpha: %1.2f',alphaDeg))
        line([-Geometrie.R Geometrie.R],[Geometrie.l Geometrie.l])
        hold off;

    case 'K'
        % Winkel in Grad
        alphaDeg = Geometrie.alpha / pi * 180;
        % Flammenfront Funktion
        F = -y * cot(Geometrie.alpha) + Geometrie.l + Geometrie.H;
        F_mirror = F(end:-1:1);
        % Plot
        plot(axes,[-1*y(end:-1:1),y],[F_mirror,F],'r','LineWidth',2); hold on
        title(sprintf('alpha:  %1.2f',alphaDeg))
        line([-Geometrie.R Geometrie.R],[Geometrie.l Geometrie.l])
        hold off;
   
    case 'M'
        % Winkel in Grad
        alphaDegV = Geometrie.V.alpha / pi * 180;
        alphaDegK = Geometrie.K.alpha / pi * 180;

        % An welcher Stelle im y-Vektor endet V-Flamme?
        [y_VKval,~] = max(y(y<Geometrie.V.R));
        
        
        % Add more cells if boarder is no captured well enough
        while abs(y_VKval - Geometrie.V.R) > 0.001*Geometrie.R && n < 1000
            n = n * 2; 
            y = linspace(0,Geometrie.R,n);
        end
            
        [~,y_VK] = max(y(y<Geometrie.V.R));
        
        % Initialisieren von F
        F = zeros(1,n);
        
        % Flammenfront Funktion: V-Anteil
        F(1:y_VK) = y(1:y_VK) * cot(Geometrie.V.alpha) + Geometrie.V.l;
        % Flammenfront Funktion: K-Anteil
        F(y_VK+1:end) = ( Geometrie.K.R - y(y_VK+1:end) ) * cot(Geometrie.K.alpha) + Geometrie.K.l ;
        
        F_mirror = F(end:-1:1);
        
        % Plot        
        plot(axes,[-1*y(end:-1:1),y],[F_mirror,F],'r','LineWidth',2); hold on
        title(sprintf('alpha V:  %1.2f, alpha K:  %1.2f',alphaDegV,alphaDegK))
        line([-Geometrie.R Geometrie.R],[Geometrie.V.l Geometrie.V.l]);
        line([-Geometrie.R Geometrie.R],[Geometrie.K.l Geometrie.K.l])
        hold off;
        
end

% Exort
% filename = ['M_flame_',num2str(Param.gamma)];
% export_fig( fg, ...      % figure handle
%     filename,... % name of output file without extension
%     '-painters', ...      % renderer
%     '-pdf' ...           % file format
%     );             % resolution in dpi
saveas(fg, [Param.OutputFolder,'PlotGeometrie'], 'png');
close(fg)

Logging(Param.filename,1,sprintf('Geometrie gezeichnet mit %d Punkten',n))

end