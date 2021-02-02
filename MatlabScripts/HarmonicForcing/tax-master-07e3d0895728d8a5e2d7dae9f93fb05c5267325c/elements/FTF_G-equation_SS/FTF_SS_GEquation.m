function [G_flameSS,StateSpace,Velocity,Geometrie,Param,DiscSpace] = FTF_SS_GEquation(makeNoDim, Param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Erklaehrung
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bedeutung der Strukturen:
%   Param:      Enthaelt alle Physikalischen Parameter sowie die
%               Modellparameter: i.A. Dimensionsbehaftet!
%   Geometrie:  Enthaelt alle Geometrischen Groessen dimensionsfrei!
%   GeometrieD: Enthaelt alle Geometrischen Groessen dimensionsbehaftet!
%   Velocity:   Enthaelt alle Geschwindigkeiten dimensionsfrei!
%   VelocityD:  Enthaelt alle Geschwindigkeiten dimensionsbehaftet!
%   StateSpace: Enthaelt alle Vektoren und Matrizen, die das System in
%               State-Space Schreibweise beschreiben, also A,b und C sowie
%               die Diskretisierung von Y:
%                   dxi_dt(Y,t) = A xi(Y,t) + b u_in'(t)
%                   A'(t)/A_m   = C xi(Y,t)
%
% Bedeutung des Eingangsparameters makeNoDim: 
%   true :      Alle Groessen werden entdimensionalisiert (vgl. mit Paper
%               Ralf moeglich)
%   false:      Keine Entdimensionalisierung

%% relativen Pfad zu Funktionen hinzufuegen
% addpath 'functions'

%% Initialisierung des Logs
% filename = 'StateSpace.log';
% Logging(filename,0,'')
% Logging(filename,5,'Berechnung der State Space Representation gestartet!')

%% Set Parameters
% Param = SetParamTaX(filename);
% Param.filename = filename;

%% Berechnung der Geometrischen Daten u. Geschwindigkeiten aus Parametern + Plot der Flammenform
% dimensionsbehaftet
[Geometrie, Velocity] = CalcGeomVel(Param);
% Dimensionslos
if makeNoDim
    [Geometrie, Velocity] = MakeNoDim(Geometrie, Velocity, Param);
end

%% Zeichnen der Geometrie
if 0
    DrawGeometrie(Param,Geometrie,'new')
end

%% Diskretisierung des Raumes
DiscSpace = CalcDiscretisationSpace(Param,Geometrie);

%% System aufstellen
if Param.Flammentyp == 'M'
    % V-Anteil
    StateSpace.V = MakeSys(Param,DiscSpace.V,Geometrie.V,Velocity.V);
    % K-Anteil
    StateSpace.K = MakeSys(Param,DiscSpace.K,Geometrie.K,Velocity.K);
else
    % Nur V- oder Konische Flamme
    StateSpace = MakeSys(Param,DiscSpace,Geometrie,Velocity);
end
% Logging(Param.filename,1,'System created!')

%% State Space Representation bestimmen (mit time delays)
[StateSpace] = CalcStateSpace(StateSpace,Param,DiscSpace);
G_flameSS = StateSpace.sys;

% %% Erfolgreiches Beenden des Programms
% Logging(Param.filename,4,'')

end