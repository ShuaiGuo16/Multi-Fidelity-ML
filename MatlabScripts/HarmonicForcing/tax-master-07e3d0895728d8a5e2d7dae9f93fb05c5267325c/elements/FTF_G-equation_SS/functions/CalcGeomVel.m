function [Geometrie, Velocity] = CalcGeomVel(Param)
% Funktion bestimmt alle abhaengigen geometrischen Groessen 
% aus der gegebenen Geometrie sowie die Geschwindigkeiten in
% Flammenkoordinaten

Logging(Param.filename,1,'Berechnung der Geometrie und Geschwindigkeiten:')

switch Param.Flammentyp
    case 'V'
        Geometrie.type = Param.Flammentyp;
        % Winkel alpha in Bogenmass
        Geometrie.alpha = atan( Param.R / Param.H );
        % Radius der Flamme
        Geometrie.R = Param.R;
        % Laenge der Flamme
        Geometrie.Lf = Geometrie.R / sin(Geometrie.alpha);       
        % Hoehe der Flamme
        Geometrie.H = Param.H;
        % Fuer Totzeit relevante Hoehe der Flamme (= 0 , da duct mit THX
        % modelliert!)
        Geometrie.l = 0;
        
        % Berechnung der mittleren Oberflaeche A_m
        Geometrie.A_m = pi * Geometrie.R^2/sin(Geometrie.alpha);
        
        % Berechnung der Geschwindigkeiten
        Velocity.Um = Param.um * sin(Geometrie.alpha) - Param.vm * cos(Geometrie.alpha);
        Velocity.Vm = Param.um * cos(Geometrie.alpha) + Param.vm * sin(Geometrie.alpha);
        Velocity.W  = Param.W;
        Velocity.soundSpeed = Param.soundSpeed;    
        
        Logging(Param.filename,1,['\t','Alpha: ', num2str(Geometrie.alpha) ])
        Logging(Param.filename,1,['\t','L_f: ', num2str(Geometrie.Lf) ])
        Logging(Param.filename,1,['\t','A_m: ', num2str(Geometrie.A_m) ])
        Logging(Param.filename,1,['\t','U_m: ', num2str(Velocity.Um) ])
        Logging(Param.filename,1,['\t','V_m: ', num2str(Velocity.Vm) ])
    case 'K'
        Geometrie.type = Param.Flammentyp;
        % Winkel alpha in Bogenmass
        Geometrie.alpha = atan( Param.R / Param.H );
        % Radius der Flamme
        Geometrie.R = Param.R;
        % Laenge der Flamme
        Geometrie.Lf = Geometrie.R / sin(Geometrie.alpha);       
        % Hoehe der Flamme
        Geometrie.H = Param.H;
        % Fuer Totzeit relevante Hoehe der Flamme (= 0 , da duct mit THX
        % modelliert!)
        Geometrie.l =0;       
        
        % Berechnung der mittleren Oberflaeche A_m
        Geometrie.A_m = pi * Geometrie.R^2/sin(Geometrie.alpha);
        
        % Berechnung der Geschwindigkeiten
        Velocity.Um = Param.um * sin(Geometrie.alpha) - Param.vm * cos(Geometrie.alpha);
        Velocity.Vm = Param.um * cos(Geometrie.alpha) + Param.vm * sin(Geometrie.alpha);
        Velocity.W  = Param.W;
        Velocity.soundSpeed = Param.soundSpeed;       
        
        Logging(Param.filename,1,['\t','Alpha: ', num2str(Geometrie.alpha) ])
        Logging(Param.filename,1,['\t','L_f: ', num2str(Geometrie.Lf) ])
        Logging(Param.filename,1,['\t','A_m: ', num2str(Geometrie.A_m) ])
        Logging(Param.filename,1,['\t','U_m: ', num2str(Velocity.Um) ])
        Logging(Param.filename,1,['\t','V_m: ', num2str(Velocity.Vm) ])
    case 'M'
        if Param.gamma < 0 || Param.gamma > 1
            Logging(3,'Der Wert fuer gamme muss zwischen 0 und 1 liegen!')
        end
        %%%%%% Gesamt 
        % Hoehe
        Geometrie.H = Param.H; 
        % Radius der Flamme
        Geometrie.R = Param.R;
        
        
        % Fuer Totzeit relevante Hoehe der Flamme
        % Zunaechst kleineren duct zu Null setzen (duct in THX!)
        bias = min(Param.l2,Param.l1);
        Param.l2 = Param.l2 - bias;
        Param.l1 = Param.l1 - bias;
        
        Geometrie.V.l = Param.l2; 
        Geometrie.K.l = Param.l1;
        
        % Welcher Flammenteil ist hoeher?
        if Geometrie.K.l < Geometrie.V.l
            Geometrie.V.H = Param.H - abs(Param.l1-Param.l2);
            Geometrie.K.H = Param.H;
        else
            Geometrie.K.H = Param.H - abs(Param.l1-Param.l2);
            Geometrie.V.H = Param.H;
        end
        
        
        %%%%%% V- Anteil
        Geometrie.V.type = 'V';
        % Radius
        Geometrie.V.R = Param.R * Param.gamma;
        % Winkel
        Geometrie.V.alpha = atan( Geometrie.V.R / Geometrie.V.H);
        % Laenge der Flamme
        Geometrie.V.Lf = Geometrie.V.R / sin(Geometrie.V.alpha);        
                
        
        % Berechnung der Geschwindigkeiten
        Velocity.V.Um = Param.um * sin(Geometrie.V.alpha) - Param.vm * cos(Geometrie.V.alpha);
        Velocity.V.Vm = Param.um * cos(Geometrie.V.alpha) + Param.vm * sin(Geometrie.V.alpha);
        Velocity.V.W  = Param.W;
        Velocity.V.soundSpeed = Param.soundSpeed;       
        
        Logging(Param.filename,1,['\t','Alpha_V: ', num2str(Geometrie.V.alpha) ])
        Logging(Param.filename,1,['\t','L_f_V: ', num2str(Geometrie.V.Lf) ])       
        Logging(Param.filename,1,['\t','U_m_V: ', num2str(Velocity.V.Um) ])
        Logging(Param.filename,1,['\t','V_m_V: ', num2str(Velocity.V.Vm) ])
        
        
        %%%%%% K-Anteil
        Geometrie.K.type = 'K';
        % Radius
        Geometrie.K.R = Param.R;
        % Winkel       
        Geometrie.K.alpha = atan( (Geometrie.K.R - Geometrie.V.R) / Geometrie.K.H);
        % Laenge der Flamme
        Geometrie.K.Lf = (Geometrie.K.R - Geometrie.V.R) / sin(Geometrie.K.alpha);
              

        % Berechnung der Geschwindigkeiten
        Velocity.K.Um = Param.um * sin(Geometrie.K.alpha) + Param.vm * cos(Geometrie.K.alpha);
        Velocity.K.Vm = Param.um * cos(Geometrie.K.alpha) - Param.vm * sin(Geometrie.K.alpha);
        Velocity.K.W  = Param.W;
        Velocity.K.soundSpeed = Param.soundSpeed;
        
        Logging(Param.filename,1,['\t','Alpha_K: ', num2str(Geometrie.K.alpha) ])
        Logging(Param.filename,1,['\t','L_f_K: ', num2str(Geometrie.K.Lf) ])       
        Logging(Param.filename,1,['\t','U_m_K: ', num2str(Velocity.K.Um) ])
        Logging(Param.filename,1,['\t','V_m_K: ', num2str(Velocity.K.Vm) ])
        
        % Berechnung der mittleren Oberflaeche A_m: Summe aus K- und
        % V-Oberflaeche!
        A_m_V = pi * Geometrie.V.R^2/sin(Geometrie.V.alpha);
        A_m_K = ( pi / sin(Geometrie.K.alpha) ) * ( Geometrie.K.R^2 - Geometrie.V.R^2 );
        A_m_ges = A_m_V + A_m_K;
        
        Geometrie.K.A_m = A_m_ges;
        Geometrie.V.A_m = A_m_ges;
        
        Logging(Param.filename,1,['\t','A_m_M: ', num2str(A_m_ges) ])
end



end

