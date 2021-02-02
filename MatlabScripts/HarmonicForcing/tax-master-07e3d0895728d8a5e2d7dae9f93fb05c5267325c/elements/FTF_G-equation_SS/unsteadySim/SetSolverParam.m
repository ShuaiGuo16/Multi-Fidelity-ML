function Solver = SetSolverParam(Param,Velocity,DiscSpace)
%% Setzen der Parameter (hier editieren!)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wahl des Zeitlichen Integrators/ Solvers.
%   CrankNicolson
%   EulerExplicit
%   ode45           Recommended!
%   ode23
Solver.tsolver = 'ode45';

t_end = 3;    % [s] Simulationsendzeit
t_start = 0;   % [s] Simulationsstartzeit

%%%% Zeit-Diskretisierung (nur fuer CrankNicolson und EulerExplicit)
nt = 500;      % Anzahl der Zeitschritte

% Art der Anregung
%   harmonic
%   IR
Solver.InputFun = 'IR';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%% Berechnung der Solver-Parameter: Anregung
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Solver.InputFun,'harmonic')
    Solver.U_in_amp = 0.05;    % [in % von u_mean]
    Solver.U_in_omega = 5;      % [1/s] in Bogenmass!
    
    % String mit Funktion des Eingangssignales in Abh. von t (Klammern
    % aussenherum nicht vergessen!)
    % -pi/2, da Auslenkung zunaecgst Null sein soll
    % Harmonic Input (nicht mit u_m normiert!!)
    Solver.U_in = '( Param.um*Solver.U_in_amp*exp(1i* ( (Solver.U_in_omega)*t -pi/2) ) )';
    
elseif strcmp(Solver.InputFun,'IR')
    % Impuls-Response (approx) (nicht mit u_m normiert!!)
    Solver.widthImpulse = 1e-4;
    Solver.U_in = 'Param.um * 1/sqrt(2*pi*Solver.widthImpulse)*exp(-(t-1)^2/(2*Solver.widthImpulse))';
end

% Unterscheide Flammentypen
switch Param.Flammentyp
    case 'V'
        Solver.U_in = eval(['@(t) ', Solver.U_in, '/ Param.um']); % Baut Annonyme Funktion aus String
    case 'K'
        Solver.U_in = eval(['@(t) ', Solver.U_in, '/ Param.um']); % Baut Annonyme Funktion aus String
    case 'M'
        Solver.V.U_in = eval(['@(t) ', Solver.U_in, '/ Param.um']); % Baut Annonyme Funktion aus String
        Solver.K.U_in = eval(['@(t) ', Solver.U_in, '/ Param.um']); % Baut Annonyme Funktion aus String
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Berechnung der Solver-Parameter: Diskretisierung und Start-/ Endzeiten
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Unterscheide Flammentypen
if Param.Flammentyp == 'M'
    %%%%%%%% V-Anteil
    %%% Zeit
    Solver.V.nt = nt;
    Solver.V.t_start = t_start;
    Solver.V.t_end = t_end;
    Solver.V.dt = (Solver.V.t_end - Solver.V.t_start) / Solver.V.nt;
    %%% Initialbedingung
    Solver.V.f_ini = zeros(DiscSpace.V.nY,1);
    
    % Nyquist-Frequenz berechnen
    Solver.V.f_NQ = 2 * pi * Velocity.V.Vm / (2 * DiscSpace.V.dY);
    
    %%%%%%%% K-Anteil
    %%% Zeit
    Solver.K.nt = nt;
    Solver.K.t_start = t_start;
    Solver.K.t_end = t_end;
    Solver.K.dt = (Solver.K.t_end - Solver.K.t_start) / Solver.K.nt;
    % Initialbedingung
    Solver.K.f_ini = zeros(DiscSpace.K.nY,1);
    
    % Nyquist-Frequenz berechnen
    Solver.K.f_NQ = 2 * pi * Velocity.K.Vm / (2 * DiscSpace.K.dY);
else
    %%% Zeit
    Solver.nt = nt;
    Solver.t_start = t_start;
    Solver.t_end = t_end;
    Solver.dt = (Solver.t_end - Solver.t_start) / Solver.nt;
    % Initialbedingung
    Solver.f_ini = zeros(DiscSpace.nY,1);
    
    % Nyquist-Frequenz berechnen
    Solver.f_NQ = 2 * pi * Velocity.Vm / (2 * DiscSpace.dY);
end

Logging(Param.filename,1,['\t','Solver: ', num2str(Solver.tsolver) ])
Logging(Param.filename,1,['\t','t_end: ', num2str(t_end) ])

end
