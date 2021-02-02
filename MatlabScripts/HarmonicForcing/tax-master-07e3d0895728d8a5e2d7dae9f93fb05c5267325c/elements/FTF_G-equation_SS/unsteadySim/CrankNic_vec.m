function [f_CN_mat,t_vec] = CrankNic_vec(A_mat,b_vec,Solver)
% Loest ODEs in der Standard-Form
% df_dt = Ax + b
% vom Zeitpunkt t_1 bis zum Zeitpunkt t_2 fuer einen Zeitschritt h
% der b-vector ist eine Annonyme Funktion (!!) und von der Zeit abhaengig

% Berechnen der Anzahl der Zeitschritte
n_t = Solver.nt;
h = Solver.dt;

% Identitätsmatrix
I_mat = eye(length(Solver.f_ini));

%Initialisieren der Lösungsmatrix und des Zeitvektors
f_CN_mat = zeros(length(Solver.f_ini),n_t);
t_vec = zeros (1,n_t);

% Einsetzen der Anfangsbedingung
f_CN_mat(:,1) = Solver.f_ini;
t_vec(1) = Solver.t_start;

% Berechnung der Systemmatrizen
A_tilde = (I_mat - (h/2)*A_mat);
B_tilde = (I_mat+(h/2)*A_mat);
    
% Beginn der Iteration    
for n=2:n_t
    t = (n-1)*h;
    f_CN_mat(:,n) = A_tilde \ ( B_tilde*f_CN_mat(:,n-1) + h*b_vec(t));
    t_vec(n) = t;
end

end
