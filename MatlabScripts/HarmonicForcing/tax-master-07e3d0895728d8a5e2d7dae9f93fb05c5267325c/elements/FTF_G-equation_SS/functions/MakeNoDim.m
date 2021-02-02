function [Geometrie, Velocity] = MakeNoDim(GeometrieD, VelocityD, Param)

if Param.Flammentyp == 'M'    
    % M-Flamme
    %%%%% Groessen mit denen entdimensionalisiert wird   
    length = GeometrieD.H;
    velocity = Param.um * cos(max(GeometrieD.K.alpha,GeometrieD.V.alpha));
    
    %%%%% Durchfuehren der Entdimensionalisierung
    % Allgemeine Groessen
    Geometrie.H = GeometrieD.H / length;
    Geometrie.R = GeometrieD.R / length;
    
    %%% V-Anteil
    % Geometrie
    Geometrie.V.type = GeometrieD.V.type;
    Geometrie.V.alpha = GeometrieD.V.alpha;
    Geometrie.V.R = GeometrieD.V.R / length;
    Geometrie.V.Lf = GeometrieD.V.Lf / length;
    Geometrie.V.H = GeometrieD.V.H / length;
    Geometrie.V.l = GeometrieD.V.l / length;
    Geometrie.V.A_m = GeometrieD.V.A_m / length^2;
    
    % Velocity
    Velocity.V.Um = VelocityD.V.Um / velocity;
    Velocity.V.Vm = VelocityD.V.Vm / velocity;
    Velocity.V.W = VelocityD.V.W / velocity;
    Velocity.V.soundSpeed = Param.soundSpeed / velocity;
    

    %%% K-Anteil
    % Geometrie
    Geometrie.K.type = GeometrieD.K.type;
    Geometrie.K.alpha = GeometrieD.K.alpha;
    Geometrie.K.R = GeometrieD.K.R / length;
    Geometrie.K.Lf = GeometrieD.K.Lf / length;
    Geometrie.K.H = GeometrieD.K.H / length;
    Geometrie.K.l = GeometrieD.K.l / length;
    Geometrie.K.A_m = GeometrieD.K.A_m / length^2;
    
    % Velocity
    Velocity.K.Um = VelocityD.K.Um / velocity;
    Velocity.K.Vm = VelocityD.K.Vm / velocity;
    Velocity.K.W = VelocityD.K.W / velocity;
    Velocity.K.soundSpeed = Param.soundSpeed / velocity;
    

else
    % Nur V- oder Konische Flamme
    %%%%% Groessen mit denen entdimensionalisiert wird   
    length = GeometrieD.Lf;
    velocity = Param.um * cos(GeometrieD.alpha);
    
    %%%%% Durchfuehren der Entdimensionalisierung
    % Geometrie
    Geometrie.type = GeometrieD.type;
    Geometrie.alpha = GeometrieD.alpha;
    Geometrie.R = GeometrieD.R / length;
    Geometrie.Lf = GeometrieD.Lf / length;
    Geometrie.H = GeometrieD.H / length;
    Geometrie.l = GeometrieD.l / length;
    Geometrie.A_m = GeometrieD.A_m / length^2;
    
    % Velocity
    Velocity.Um = VelocityD.Um / velocity;
    Velocity.Vm = VelocityD.Vm / velocity;
    Velocity.W = VelocityD.W / velocity;
    Velocity.soundSpeed = Param.soundSpeed / velocity;
    
end

Logging(Param.filename,1,'Entdimensionalisierung aller Groessen durchgefuehrt!')
end