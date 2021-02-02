function PlotFlameSurf3DVid(Param,StateSpace,SolutionT,Geometrie,Solver)
snapshot = true;
step_snapshot = 450; %[s]

Logging(Param.filename,1,'Creating a 3D Video...')

filename = [Param.OutputFolder,'2D_FlameFront_', Param.Flammentyp, '-Flame_',Param.VModell,'_',Solver.InputFun,'.gif'];

% Waehle Anzahl an Frames
AnzFrame = 300;


if Param.Flammentyp == 'M'
    fig = figure;
    set(fig, 'Position', [0 0 900 550])
    lengthVid = min(length(SolutionT.V.t_vec),length(SolutionT.K.t_vec));
       
    sample = 2*floor(lengthVid / AnzFrame);
    
    for n=1:sample:lengthVid
        % V-Anteil
        % Berechnen des Radius
        rad_vecV = sin(Geometrie.V.alpha)*StateSpace.V.Y  - cos(Geometrie.V.alpha)*SolutionT.V.f_mat(:,n);
        
        % K-Anteil
        rad_vecK = Geometrie.V.R + sin(Geometrie.K.alpha)*(Geometrie.K.Lf-StateSpace.K.Y)  + cos(Geometrie.K.alpha)*SolutionT.K.f_mat(:,n);
        
        % Zylinder-Plot
        [XV,YV,ZV] = cylinder(real(rad_vecV),32); 
        [XK,YK,ZK] = cylinder(real(rad_vecK),32);
        
        
         [~,dimX] = size(XV);
        m = floor(dimX / 2 ) ;
        XV(:,m+2:end) = [];
        YV(:,m+2:end,:) = [];
        ZV(:,m+2:end,:) = [];
        
        XK(:,m+2:end) = [];
        YK(:,m+2:end,:) = [];
        ZK(:,m+2:end,:) = [];
        
        subplot(2,2,[1 3])
        surf(XV,YV,ZV); hold on;                   
        surf(XK,YK,ZK); hold off;
        alphaDegV = Geometrie.V.alpha / pi * 180;
        alphaDegK = Geometrie.K.alpha / pi * 180;
        title(sprintf('Surface (alpha_K=%1.2f deg, alpha_V=%1.2f)',alphaDegK,alphaDegV))
        
        
        %%%%%%%%%%%% Formatierung
        colormap(hot)

        % Achenbeschriftung
        set( gca                       , ...
            'FontName'   , 'Helvetica' , ...
            'FontSize'      , 14        );
        
        % Beleuchtung
%         camlight right
%         lighting phong
        set(gca, 'XLim'     ,[-2,2], ...
                 'YLim'     ,[-2,2], ...
                 'ZLim'     ,[0,1]     );
             
        % 2 D Plots
        % Plot der Flaechenschwankung
        subplot(2,2,2)              
        plot(SolutionT.t_vec,real(SolutionT.FlucArea)); hold on
        line([SolutionT.t_vec(n) SolutionT.t_vec(n)],[min(real(SolutionT.FlucArea)) max(real(SolutionT.FlucArea))])
        title('rel. Heat Release Rate Fluctuation')
        hold off;
        
        % Plot des Eingangssignales
        u_in = arrayfun(Solver.V.U_in, SolutionT.t_vec);
        subplot(2,2,4)              
        plot(SolutionT.t_vec,real(u_in)); hold on
        line([SolutionT.t_vec(n) SolutionT.t_vec(n)],[min(real(u_in)) max(real(u_in))])
        title('Input Signal: rel. velocity fluctuation')
        hold off;
        
        
        %%%%%%%%%%%%%saveas(fg, ['movie/T-Verlauf_',num2str(n,'%.3d')], 'png');
        drawnow
        frame = getframe(fig);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,512);
        if n == 1;
            imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
        else
            imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0);
        end
        clf
        
    end
else
    fig = figure;  
    set(fig, 'Position', [0 0 900 550])
    
    sample = floor(length(SolutionT.t_vec) / AnzFrame);
            
    for n=1:sample:length(SolutionT.t_vec)
        % Berechnen des Radius
        if strcmp(Geometrie.type,'V')
            rad_vec = sin(Geometrie.alpha)*StateSpace.Y  - cos(Geometrie.alpha)*SolutionT.f_mat(:,n);
        elseif strcmp(Geometrie.type,'K')
            rad_vec = sin(Geometrie.alpha)*(Geometrie.Lf-StateSpace.Y)  + cos(Geometrie.alpha)*SolutionT.f_mat(:,n);
        end
        
        
        % Zylinder-Plot 3D    
        % Zylinder mit Hoehe 1
        [X,Y,Z] = cylinder(real(rad_vec),32);
        
        % Hoehe anpassen
        Z = Z .* Geometrie.H;
        
        [~,dimX] = size(X);
        m = floor(dimX / 2 ) ;
        X(:,m+2:end) = [];
        Y(:,m+2:end,:) = [];
        Z(:,m+2:end,:) = [];
        
        
        subplot(3,2,[1 3 5])
%         surf(X,Y,Z,ones(size(Z)));    % Einfarbig
        
        surf(X,Y,Z);                    % Mehrfarbig
        alphaDeg = Geometrie.alpha / pi * 180;
        title(sprintf('Surface (alpha=%1.2f deg)',alphaDeg))
              
        %%%%%%%%%%%% Formatierung
        colormap(hot)
               
        % Achenbeschriftung
        set( gca                       , ...
            'FontName'   , 'Helvetica' , ...
            'FontSize'      , 14        );
        
%         % Beleuchtung
%         camlight right
%         lighting phong
        PlotValue = max(Geometrie.R,Geometrie.H);
        set(gca, 'XLim'     ,[-PlotValue,PlotValue], ...
                 'YLim'     ,[-PlotValue,PlotValue], ...
                 'ZLim'     ,[0,PlotValue]     );

        
             
        % 2 D Plots
        % Plot der Flaechenschwankung
        subplot(3,2,2)              
        plot(SolutionT.t_vec,real(SolutionT.FlucArea)); hold on
        line([SolutionT.t_vec(n) SolutionT.t_vec(n)],[min(real(SolutionT.FlucArea)) max(real(SolutionT.FlucArea))])
        title('Heat Release Rate Fluctuation')
        hold off;
        
        % Plot des Eingangssignales
        u_in = arrayfun(Solver.U_in, SolutionT.t_vec);
        subplot(3,2,4)              
        plot(SolutionT.t_vec,real(u_in)); hold on
        line([SolutionT.t_vec(n) SolutionT.t_vec(n)],[min(real(u_in)) max(real(u_in))])
        title('Input Signal')
        hold off;
        
        % Plot der Oberflaeche in X-Y Koordinaten
        subplot(3,2,6)  
        plot(StateSpace.Y,real(SolutionT.f_mat(:,n)))     
        set(gca, 'XLim'     ,[0,max(StateSpace.Y)], ...
                 'YLim'     ,[-1,1]    );        
        title('Surface X-Y-System')
        
        %saveas(fg, ['movie/T-Verlauf_',num2str(n,'%.3d')], 'png');
        drawnow
        frame = getframe(fig);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,512);
        if n == 1;
            imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',0);
        else
            imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0);
        end
        
        
%         % Falls gewuenscht, wird ein Einzelbild herausgeschrieben
%         if snapshot && abs(step_snapshot - n) < sample
%             fig3D = figure();
%             set(gcf,'color','w');
%             surf(X,Y,Z);                    % Mehrfarbig
%             alphaDeg = Geometrie.alpha / pi * 180;
%             title(sprintf('Surface (alpha=%1.2f deg)',alphaDeg))
%             
%             %%%%%%%%%%%% Formatierung
%             colormap(hot)
%             
%             % Achenbeschriftung
%             set( gca                       , ...
%                 'FontName'   , 'Helvetica' , ...
%                 'FontSize'      , 14        );
%             
%             %         % Beleuchtung
%             %         camlight right
%             %         lighting phong
%             PlotValue = max(Geometrie.R,Geometrie.H);
%             set(gca, 'XLim'     ,[-PlotValue,PlotValue], ...
%                 'YLim'     ,[-PlotValue,PlotValue], ...
%                 'ZLim'     ,[0,PlotValue]     );
%             
%             % Export
% %             filename2 = ['FlameShape_',Param.Flammentyp,'_',num2str(SolutionT.t_vec(n))];
% %             export_fig( fig3D, ...      % figure handle
% %                 filename2,... % name of output file without extension
% %                 '-painters', ...      % renderer
% %                 '-pdf' ...           % file format
% %                 );             % resolution in dpi
%             
%             saveas(fig3D, [Param.OutputFolder,'FlameShape_',Param.Flammentyp,'_',num2str(SolutionT.t_vec(n))], 'png');
%             
%             snapshot = false;
%             close(fig3D);
%         end

    clf
    end
end

close(fig);
Logging(Param.filename,1,'3D Video created!')
end