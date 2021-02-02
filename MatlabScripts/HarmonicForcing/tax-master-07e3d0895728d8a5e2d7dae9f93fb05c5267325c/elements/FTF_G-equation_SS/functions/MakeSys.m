function StateSpace = MakeSys(Param,DiscSpace,Geometrie,Velocity)
% Funktion erstellt die Matrizen/ Vektoren eins Systems der Form 
% xi_t = A*xi + b*u_in'
% out = C*xi
% erzeugt

Logging(Param.filename,1,['Creating System ', Geometrie.type, '-Flame...'])

% Diskretisierung der Y-Achse
StateSpace.Y = linspace(0,Geometrie.Lf,DiscSpace.nY)';

% Raum Diskretisierung -> A
StateSpace.A = MakeA(Velocity,DiscSpace);

% Eingangsgroesse -> b-Vektor
[StateSpace.b,StateSpace.tau] = Makeb(Param,Geometrie,Velocity,DiscSpace,StateSpace);

% Integration der Flaechenschwankung -> C
StateSpace.C = MakeC(Geometrie,DiscSpace);



end



%% Diskretisierung des Raumes
function A = MakeA(Velocity,DiscSpace)
% Berechnung der Dimension + Schrittweite
dimA = DiscSpace.nY;
dY = DiscSpace.dY;

% Initialisierung der Matrix
A = zeros(dimA);

% Befuellen der Matrix
factor = -Velocity.Vm / (2*dY);

if strcmp(DiscSpace.SchemeSpace,'upwind')
    % second order upwind scheme
    for ii=3:dimA
        A(ii,ii-2:ii) = [1, -4 , 3] * factor;
    end
    % RB (central difference)
%     A(1,1:3) = [0 0 0] * factor;
    A(2,1:3) = [-1, 0 , 1] * factor;
elseif strcmp(DiscSpace.SchemeSpace,'central')
    % central differences
    for ii=2:dimA-1
        A(ii,ii-1:ii+1) = [-1, 0 , 1] * factor;
    end
    % RB (second order upwind)
%     A(1,1:3) = [0 0 0] * factor;
    A(end,end-2:end) = [1 -4 3] * factor;
else
    Logging(Param.filename,3,'No valid discretisation scheme chosen!')
end


% % Matrix a als sparse speichern (wird von ss zu full zurueckkonvertiert,
% daher wird diese Zeile erst zur zeitl. Integration verwendet
% A = sparse(A);

end



%% Eingangsgroesse
function [b,tau] = Makeb(Param,Geometrie,Velocity,DiscSpace,StateSpace)
% Berechnung der Dimension
dimA = DiscSpace.nY;


if strcmp(Param.VModell,'uniform')
    % Uniform Velocity model
    b = cos(Geometrie.alpha) * ones(dimA,1);
    % Time delay
    tau = zeros(dimA,1);
    
elseif strcmp(Param.VModell,'convective')
    % Convective Velocity model
    b = cos(Geometrie.alpha) * ones(dimA,1);
    % Time delay
    tau = StateSpace.Y * cos(Geometrie.alpha) / Velocity.W ;    
end

% RB am unteren Rand: Flamme wird am Flameholder fixiert
% WICHTIG, da ansonsten keine Restoration!
b(1) = 0;

end




%% Integration der Oberflaeche
function C = MakeC(Geometrie,DiscSpace)
% Berechnung der Dimension + Schrittweite
dimA = DiscSpace.nY;
dY = DiscSpace.dY;

% Vorzeichen bestimmen
if Geometrie.type == 'V'
    VZ = -1;
elseif Geometrie.type == 'K'
    VZ = 1;
else
    Logging(Param.filename,3,'Flameype unknown!')
end

% Vorfaktor bestimmen
facSimpson = ( dY / 3 );
% facAm = VZ * 2 * pi *cos(Geometrie.alpha) / Geometrie.A_m;
facAm = 2 * pi /tan(Geometrie.alpha) / Geometrie.A_m;

% C-Vektor aus Simpson-Regel bauen
C = ones(dimA,1);
reps = floor((dimA-2)/2);

if 2* reps < dimA - 2
    % Nur Simpsonregel
    C(2:end-2) = repmat([4;2],reps,1);
    C(end-1) = 4;
else
    % Simpsonregel + 1x Trapez am Ende
    C(2:end-1) = repmat([4;2],reps,1);
    C(end-1:end) = [5/2;3/2];
end

C = C * facSimpson * facAm;


%% Schuller Flaechenmodell fuer V-Flamme
if Geometrie.type == 'V'
    C(end) =  - facAm * Geometrie.Lf - C(end);
end
    
    
%%%%%%%%%%% Test Integration
% C = C * facSimpson ;
% a = 0;
% b = Geometrie.Lf;
% xi = linspace(0,Geometrie.Lf,dimA)';
% % f = 2 * xi.^2 - 2*xi + 1;
% % Int = ( 2/3 * b^3 - b^2 + b - (2/3 * a^3 - a^2 + a) )
% % f = 2*xi;
% % Int = b^2 - a^2
% omega = 100;
% f = 2*sin(xi*omega);
% Int = -2/omega * ( cos(b*omega) -cos(a*omega) )
% 
% Int_vec = C' * f

end