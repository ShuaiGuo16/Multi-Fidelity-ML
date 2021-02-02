function [f_euler_mat,t_vec] = Euler_FW_vec(A_mat,b_vec,Solver)
% Loest ODEs in der Standard-Form
% df_dt = Ax + b
% vom Zeitpunkt t_1 bis zum Zeitpunkt t_2 fuer einen Zeitschritt h
% der b-vector ist eine Annonyme Funktion (!!) und von der Zeit abhaengig

% Berechnen der Anzahl der Zeitschritte
n_t = Solver.nt;
h = Solver.dt;

%Initialisieren der Lösungsmatrix und des Zeitvektors
f_euler_mat = zeros(length(Solver.f_ini),n_t);
t_vec = zeros (1,n_t);

% Einsetzen der Anfangsbedingung
f_euler_mat(:,1) = Solver.f_ini;
t_vec(1) = Solver.t_start;


    
% Beginn der Iteration    
for n=2:n_t
    t = (n-1)*h;
    f_euler_mat(:,n) = f_euler_mat(:,n-1) + h*(A_mat*f_euler_mat(:,n-1)  + b_vec(t));
    t_vec(n) = t;
end

end
