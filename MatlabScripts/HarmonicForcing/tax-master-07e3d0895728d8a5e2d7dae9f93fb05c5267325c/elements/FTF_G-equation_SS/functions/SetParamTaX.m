function Param = SetParamTaX(logFilename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameter: Physik
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Stoffgroessen
Param.soundSpeed = 333;    % [m/s]

%%%% Geschwindigkeiten
Param.um = 1;              % [m/s]   Mittlere Stroemungsgeschwindigkeit x-Richtung
Param.vm = 0;              % [m/s]   Mittlere Stroemungsgeschwindigkeit y-Richtung

Param.W = Param.um;        % [m/s]   Geschwindigkeit mit der Stoerung durch Flamme laeuft


%%%% Flammentyp:
% V (V-Flamme)
% K (konische Flamme)
% M (M-Flamme)
Param.Flammentyp = 'K';

%%%% Geschwindigkeitsmodell waehlen
% uniform
% convective
% incompConvective       NOT IMPLEMENTED!
% incompConvecDecrease   NOT IMPLEMENTED!
Param.VModell = 'convective';


%%%% Geometrie
Param.R = 0.1;              % [m]
Param.H  = 0.15;             % [m]  Flammen Hoehe

Param.gamma  = 0.5;         % [m]  Nur fuer M-Flamme relevant!
% 0<gamma<1 : Verhaeltnis Radius V-Anteil zu Gesamtradius
Param.l1 = 0;               % [m]  Nur fuer M-Flamme relevant! (keine Totzeit durch duct vor Flamme -> THX!)
Param.l2 = 0;               % [m]  Nur fuer M-Flamme relevant!

%%%% Diskretisierung des Raumes (Anzahl der Stuezpunkte)
% upwind   (recommended!)
% central
Param.SchemeSpace = 'upwind';
Param.nY = 100;

%%%% Geometrie
Param.OutputFolder = 'output/';

%% Logging
Logging(logFilename,1,'Gewaehlte Parameter: ')
ParamFields = fieldnames(Param); 
for ii = 1:numel(ParamFields) 
    Logging(logFilename,1,['\t', ParamFields{ii},': ', num2str(Param.(ParamFields{ii})) ])
end

end