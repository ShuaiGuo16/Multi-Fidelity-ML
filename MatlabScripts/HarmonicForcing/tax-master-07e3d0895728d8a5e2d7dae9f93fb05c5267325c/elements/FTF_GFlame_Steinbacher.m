%% Flame Model G-Equation
% FTF implemented by Thomas Steinbacher

function [FTFsys,pars] = FTF_GFlame_Steinbacher(pars, state)

path= mfilename('fullpath');
path = fileparts(path);
addpath(genpath(fullfile(path,filesep,'FTF_G-equation_SS')))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameter: Physik
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Stoffgroessen
Param.soundSpeed = state.c;    % [m/s]

%%%% Geschwindigkeiten
Param.um = state.Mach*state.c;              % [m/s]   Mittlere Stroemungsgeschwindigkeit x-Richtung
Param.vm = 0;              % [m/s]   Mittlere Stroemungsgeschwindigkeit y-Richtung

Param.W = Param.um;        % [m/s]   Geschwindigkeit mit der Stoerung durch Flamme laeuft


%%%% Flammentyp:
% V (V-Flamme)
% K (konische Flamme)
% M (M-Flamme)
switch(cell2mat(pars.Flammentyp))
    case 'V-Flame'
        Param.Flammentyp = 'V';
    case 'Conical Flame'
        Param.Flammentyp = 'K';
    case 'M-Flame'
        Param.Flammentyp = 'M';
end



%%%% Geschwindigkeitsmodell waehlen
% uniform
% convective
% incompConvective       NOT IMPLEMENTED!
% incompConvecDecrease   NOT IMPLEMENTED!
Param.VModell = cell2mat(pars.VModell);


%%%% Geometrie
Param.R = eval(cell2mat(pars.R));              % [m]
Param.H  = eval(cell2mat(pars.H));             % [m]  Flammen Hoehe

Param.gamma  = eval(cell2mat(pars.gamma));         % [m]  Nur fuer M-Flamme relevant!
% 0<gamma<1 : Verhaeltnis Radius V-Anteil zu Gesamtradius
Param.l1 = eval(cell2mat(pars.L1));               % [m]  Nur fuer M-Flamme relevant! (keine Totzeit durch duct vor Flamme -> THX!)
Param.l2 = eval(cell2mat(pars.L2));               % [m]  Nur fuer M-Flamme relevant!

%%%% Diskretisierung des Raumes (Anzahl der Stuezpunkte)
% upwind   (recommended!)
% central
Param.SchemeSpace = cell2mat(pars.SchemeSpace);
Param.nY = eval(cell2mat(pars.nY));

%%%% Geometrie
Param.OutputFolder = 'output/';
Param.filename = 'StateSpace.log';

%% Logging
Logging(Param.filename,1,'Gewaehlte Parameter: ')
ParamFields = fieldnames(Param); 
for ii = 1:numel(ParamFields) 
    Logging(Param.filename,1,['\t', ParamFields{ii},': ', num2str(Param.(ParamFields{ii})) ])
end

%% Generate flame Model
[G_flameSS] = FTF_SS_GEquation(false, Param);

%% Set names of signals

% [~, FlameName] = fileparts(Feedback.handle);
% [~, RefName] = fileparts(Reference{1}.handle);

FTFsys = G_flameSS;
% % FTFsys.u = {RefName};
% % FTFsys.y = {FlameName};
% 
% % Denormalize FTF reference with reference mean flow speed
% Denorm = ss(1/(Reference{1}.Connection.Mach*Reference{1}.Connection.c));
% Denorm.u = {['u_',RefName]};
% Denorm.y = {RefName};
% 
% Input  = sumblk(['u_',RefName,' = ','f_',RefName ,'-','g_',RefName]);
% 
% % Assemble input signal for FTF u'/u
% sys = connect(FTFsys, Denorm, Input, {['f_',RefName] ,['g_',RefName]}, FlameName);