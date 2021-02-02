function [SolutionT] = IntegrateODEStateSpace(Solver,Param,StateSpace,Velocity,Geometrie)
Logging(Param.filename,1,['Solving System using ', Solver.tsolver])
tic

%%% Bestimmen des b-Vektors des zu loesenden Systems (als b x u'(t) )
if Param.Flammentyp == 'M'
    % Eingangsvektor berechnen (Zeitabhaengig) als Annonyme
    % Funktion (nur für zeitl. Integration)
    if strcmp(Param.VModell,'uniform')
        %%% V-Anteil
        b_sysV = @(t) StateSpace.V.b * Solver.V.U_in(t);
        %%% K-Anteil
        b_sysK = @(t) StateSpace.K.b * Solver.K.U_in(t);
    else
        % convective velocity model
        u_in_fun = @(t) Solver.V.U_in(t);
        %%% V-Anteil
        b_sysV = @(t) StateSpace.V.b .* arrayfun(u_in_fun, t -  cos(Geometrie.V.alpha)/ Velocity.V.W * StateSpace.V.Y  );        
        %%% K-Anteil
        b_sysK = @(t) StateSpace.K.b .* arrayfun(u_in_fun, t -  cos(Geometrie.K.alpha)/ Velocity.K.W * StateSpace.K.Y  );
    end
    
    % V: Matrix A als sparse schreiben
    StateSpace.V.A = sparse(StateSpace.V.A);
    
    % K:  Matrix A als sparse schreiben
    StateSpace.K.A = sparse(StateSpace.K.A);
else
    % Eingangsvektor berechnen (Zeitabhaengig) als Annonyme
    % Funktion  (nur für zeitl. Integration)
    % Nur V- oder Konische Flamme
    if strcmp(Param.VModell,'uniform')
        % uniform velocity model
        b_sys = @(t) StateSpace.b * Solver.U_in(t);
    else
        % convective velocity model
        u_in_fun = @(t) Solver.U_in(t);
%         b_sys = eval('@(t) cos(Geometrie.alpha) * arrayfun(u_in_fun, t -  cos(Geometrie.alpha)/ Velocity.W * StateSpace.Y  )');
        b_sys = @(t) StateSpace.b .* arrayfun(u_in_fun, t -  cos(Geometrie.alpha)/ Velocity.W * StateSpace.Y  );    
    end
    
    % Matrix A als sparse schreiben
    StateSpace.A = sparse(StateSpace.A);
end

%%% Zeitl. Integration
switch Solver.tsolver
    case 'CrankNicolson'
        % Mittels Crank-Nicolson
        if Param.Flammentyp == 'M'
            % V-Anteil
            [SolutionT.V.f_mat,SolutionT.V.t_vec] = CrankNic_vec(StateSpace.V.A,b_sysV,Solver.V);
            % K-Anteil
            [SolutionT.K.f_mat,SolutionT.K.t_vec] = CrankNic_vec(StateSpace.K.A,b_sysK,Solver.K);
        else
            % Nur V- oder Konische Flamme
            [SolutionT.f_mat,SolutionT.t_vec] = CrankNic_vec(StateSpace.A,b_sys,Solver);
        end
    case 'EulerExplicit'
        % Mittels explizitem Euler
        if Param.Flammentyp == 'M'
            % V-Anteil
            [SolutionT.V.f_mat,SolutionT.V.t_vec] = Euler_FW_vec(StateSpace.V.A,b_sysV,Solver.V);
            % K-Anteil
            [SolutionT.K.f_mat,SolutionT.K.t_vec] = Euler_FW_vec(StateSpace.K.A,b_sysK,Solver.K);
        else
            % Nur V- oder Konische Flamme
            [SolutionT.f_mat,SolutionT.t_vec] = Euler_FW_vec(StateSpace.A,b_sys,Solver);
        end
    case 'ode45'
        % Benutzt den MATLAB-internen Gleichungsloeser
        options = odeset('RelTol',1e-7,'AbsTol',1e-7);
        if Param.Flammentyp == 'M'
            % V-Anteil
            odefunV = @(t,f) StateSpace.V.A*f + b_sysV(t);
            [SolutionT.V.t_vec,SolutionT.V.f_mat] = ode45(odefunV, [Solver.V.t_start Solver.V.t_end], Solver.V.f_ini,options);
            SolutionT.V.f_mat = SolutionT.V.f_mat';
            SolutionT.V.t_vec = SolutionT.V.t_vec';
            % K-Anteil
            odefunK = @(t,f) StateSpace.K.A*f + b_sysK(t);
            [SolutionT.K.t_vec,SolutionT.K.f_mat] = ode45(odefunK, [Solver.K.t_start Solver.K.t_end], Solver.K.f_ini,options);
            SolutionT.K.f_mat = SolutionT.K.f_mat';
            SolutionT.K.t_vec = SolutionT.K.t_vec';
        else
            odefun = @(t,f) StateSpace.A*f + b_sys(t);
            [SolutionT.t_vec,SolutionT.f_mat] = ode45(odefun, [Solver.t_start Solver.t_end], Solver.f_ini,options);
            SolutionT.f_mat = SolutionT.f_mat';
            SolutionT.t_vec = SolutionT.t_vec';
        end
    case 'ode23'
        options = odeset('RelTol',1e-7,'AbsTol',1e-7);
        if Param.Flammentyp == 'M'
            % V-Anteil
            odefunV = @(t,f) StateSpace.V.A*f + b_sysV(t);
            [SolutionT.V.t_vec,SolutionT.V.f_mat] = ode23(odefunV, [Solver.V.t_start Solver.V.t_end], Solver.V.f_ini,options);
            SolutionT.V.f_mat = SolutionT.V.f_mat';
            SolutionT.V.t_vec = SolutionT.V.t_vec';
            % K-Anteil
            odefunK = @(t,f) StateSpace.K.A*f + b_sysK(t);
            [SolutionT.K.t_vec,SolutionT.K.f_mat] = ode23(odefunK, [Solver.K.t_start Solver.K.t_end], Solver.K.f_ini,options);
            SolutionT.K.f_mat = SolutionT.K.f_mat';
            SolutionT.K.t_vec = SolutionT.K.t_vec';
        else
            % Benutzt den MATLAB-internen Gleichungsloeser
            odefun = @(t,f) StateSpace.A*f + b_sys(t);
            [SolutionT.t_vec,SolutionT.f_mat] = ode23(odefun, [Solver.t_start Solver.t_end], Solver.f_ini,options);
            SolutionT.f_mat = SolutionT.f_mat';
            SolutionT.t_vec = SolutionT.t_vec';
        end
    otherwise
        Logging(Param.filename,3,'No valid solver chosen!')
end
tsolveTime = toc * 1e3;
Logging(Param.filename,1,['System solved in ', num2str(tsolveTime), ' ms'])

clearvars tsolveTime



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Berechnung der Oberflaechenschwankung : A'/Am = C xi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Param.Flammentyp == 'M'
    % V-Anteil
    SolutionT.V.FlucArea = StateSpace.V.C' * SolutionT.V.f_mat;
    % K-Anteil
    SolutionT.K.FlucArea = StateSpace.K.C' * SolutionT.K.f_mat;
    
    % Gesamt: Zunaechst kleinsten t-Vektor bestimmen
    if length(SolutionT.V.t_vec) >= length(SolutionT.K.t_vec)
        SolutionT.t_vec = SolutionT.K.t_vec;
        % Loesung Beschneiden
        SolutionT.V.f_mat(:,length(SolutionT.K.t_vec)+1:end) = [];
        SolutionT.V.t_vec(length(SolutionT.K.t_vec)+1:end) = [];
        SolutionT.V.FlucArea(length(SolutionT.K.t_vec)+1:end) = [];
        
        Logging(Param.filename,1,'V-Vektor auf korrekte Laenge gebracht')
    elseif length(SolutionT.V.t_vec) < length(SolutionT.K.t_vec)
        SolutionT.t_vec = SolutionT.V.t_vec;
        % Loesung Beschneiden
        SolutionT.K.f_mat(:,length(SolutionT.V.t_vec)+1:end) = [];
        SolutionT.K.t_vec(length(SolutionT.V.t_vec)+1:end) = [];
        SolutionT.K.FlucArea(length(SolutionT.V.t_vec)+1:end) = [];
        Logging(Param.filename,1,'K-Vektor auf korrekte Laenge gebracht')
    end
    
    % Addieren der nun gleich langen Loesugnen
    SolutionT.FlucArea = SolutionT.V.FlucArea + SolutionT.K.FlucArea;
else
    SolutionT.FlucArea = StateSpace.C' * SolutionT.f_mat;
end
Logging(Param.filename,1,'Flaechenschwankung berechnet')

