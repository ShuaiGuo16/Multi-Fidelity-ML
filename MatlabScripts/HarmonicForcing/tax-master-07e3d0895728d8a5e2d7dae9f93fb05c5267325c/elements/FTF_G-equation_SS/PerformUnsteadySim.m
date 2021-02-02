function PerformUnsteadySim()
%% relativen Pfad zu Funktionen hinzufuegen
addpath 'unsteadySim'

%% Initialisierung des Logs
filename = 'unsteadySim.log';
Logging(filename,0,'')
Logging(filename,5,'Berechnung der unsteady Simulation gestartet!')

%% Entdimensionalisierung?
makeNodim = 'true';

%% Create State Space model
[~,StateSpace,Velocity,Geometrie,Param,DiscSpace] = FTF_SS_GEquation(makeNodim);
Param.filename = filename;

%% Parameter unsteady Simulation
Solver = SetSolverParam(Param,Velocity,DiscSpace);

%% Perform Unsteady Simulation
[SolutionT] = IntegrateODEStateSpace(Solver,Param,StateSpace,Velocity,Geometrie);

%% Plot der Loesung
% Video 3D
PlotFlameSurf3DVid(Param,StateSpace,SolutionT,Geometrie,Solver)

%% Erfolgreiches Beenden des Programmsc
Logging(Param.filename,4,'')
end