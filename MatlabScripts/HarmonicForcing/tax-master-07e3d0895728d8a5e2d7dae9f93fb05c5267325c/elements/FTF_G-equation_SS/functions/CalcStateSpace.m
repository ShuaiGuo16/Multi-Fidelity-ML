function [StateSpace] = CalcStateSpace(StateSpace,Param,DiscSpace)
Logging(Param.filename,1,'Berechnung eines State Space Modells...')

% Plotten des Bode-Diagramms/ IR?
DoPlot = false;

if Param.Flammentyp == 'M'
    % Matrizen aneinander haengen
    A_mat_M = [ StateSpace.V.A , zeros(DiscSpace.V.nY); StateSpace.K.A ,zeros(DiscSpace.V.nY) ];
    c_vec_M = [ StateSpace.V.C ; StateSpace.K.C ];
    b_vec_M = [ StateSpace.V.b ; StateSpace.K.b ];
    tau_vec_M = [ StateSpace.V.tau ; StateSpace.K.tau ];
    
    % prepare zero-Matrix and Vektor
    zeroMat = zeros(DiscSpace.V.nY*2,DiscSpace.V.nY*2);
    zeroVec = zeros(DiscSpace.V.nY*2,1);
    
    % Calculate all time delays
    for jj = 1:DiscSpace.V.nY*2
        b_tmp_vec = zeroVec;
        b_tmp_vec(jj) = b_vec_M(jj);
        %         StateSpace.tau(jj) = 0;
        DelayT(jj) = struct('delay',tau_vec_M(jj),'a',zeroMat,'b',b_tmp_vec,'c',zeroVec','d',0);
    end
    % Generate state space representation
    StateSpace.sys = delayss(A_mat_M,zeros(DiscSpace.V.nY*2,1),c_vec_M',0,DelayT);
    
else
    % Without delay (only uniform)
    %     StateSpace.sys = ss(StateSpace.A,StateSpace.b,StateSpace.C',0);
    % Delay terms
    % prepare zero-Matrix and Vektor
    zeroMat = zeros(DiscSpace.nY,DiscSpace.nY);
    zeroVec = zeros(DiscSpace.nY,1);
    % Calculate all time delays
    for jj = 1:DiscSpace.nY
        b_tmp_vec = zeroVec;
        b_tmp_vec(jj) = StateSpace.b(jj);
        %         StateSpace.tau(jj) = 0;
        DelayT(jj) = struct('delay',StateSpace.tau(jj),'a',zeroMat,'b',b_tmp_vec,'c',zeroVec','d',0);
    end
    % Generate state space representation
    StateSpace.sys = delayss(StateSpace.A,zeros(DiscSpace.nY,1),StateSpace.C',0,DelayT);
    
    %%% Alternative Berechnungweies (-> Thomas E.)
    %     N = 10;
    %     sysx = pade(StateSpace.sys,N);
    %     sysd = c2d(StateSpace.sys,0.025,'Tustin');
    %     sysdabsorb = absorbDelay(sysd);
    %
    %     sysdabsorbcont = d2c(sysdabsorb,'Tustin');
    
    % Space Modell : Nur Integration (Tiefpass)
    % figure
    % sys = ss(zeros(size(StateSpace.A)),StateSpace.b,StateSpace.C',0);
    % % impulse(sys)
    % bode(sys)
    
end

Logging(Param.filename,1,'Berechnung State Space Modell erfolgreich abgeschlossen!')

if DoPlot
    %%% Plots:
    fig = figure('Visible','On');
    plot(1,1)
    subplot(1,2,1)
    impulse(StateSpace.sys)
    subplot(1,2,2)
    bode(StateSpace.sys)
    
    % Exort
    filename = ['IR_Bode_',Param.Flammentyp,'_',Param.VModell];
    saveas(fig, [Param.OutputFolder,filename], 'png');
    % export_fig( fig, ...      % figure handle
    %     filename,... % name of output file without extension
    %     '-painters', ...      % renderer
    %     '-pdf' ...           % file format
    %     );             % resolution in dpi
    close(fig)
end
end