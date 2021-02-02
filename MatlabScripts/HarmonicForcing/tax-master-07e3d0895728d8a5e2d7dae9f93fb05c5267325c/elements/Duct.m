classdef Duct < AcBlock & sss
    % DUCT Acoustic modell of a duct.% simpleDuct Acoustic modell of a duct.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % sys = Duct(pars);
    % Input:   * pars.Name: string of name of the chokedExit
    %          * pars.l:    length of duct
    %          * pars.fMax: maximum frequency to be resolved by duct
    %          * pars.order: order of upwind discretization (1-3)
    %          * pars.minres: minimal resolution of longest wavelength
    %          * pars.Mach: Mach number
    %          * pars.c: speed of sound
    % optional * pars.(...): see link to AcBlock.Port definitions below to
    %          specify mean values and port properties in constructor
    % Output:  * sys: Duct object
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  16 Jun 2015
    % ------------------------------------------------------------------
    % See also: AcBlock.Port, AcBlock, Block, simpleDuct
    
    properties
        % length of duct
        l
        % order of upwind discretization (1-3)
        order
        % minimal resolution of longest wavelength
        minres
        % maximum frequency to be resolved by duct
        fMax
        % positions of sensors inside the duct
        sensorPositions
    end
    properties(Dependent)
        % spacial discretization
        dX
        % number of spatial discretization points
        N
    end
    
    methods
        function sys = Duct(pars)
            % Call empty constructors with correct in and output dimension
            % and port number
            sys@AcBlock(AcBlock.Port,AcBlock.Port);
            sys@sss(zeros(2,2));
            
            sys.Name = pars.Name;
            sys.fMax = pars.fMax;
            
            %% Create Block from Simulink using getmodel()
            if iscell(pars.l)
                sys.l = eval(cell2mat(pars.l));
                sys.order = eval(cell2mat(pars.order));
                sys.minres = eval(cell2mat(pars.minres));
                sys.sensorPositions = eval(cell2mat(pars.sensorPositions));
            else
                sys.l = pars.l;
                sys.order = pars.order;
                sys.minres = pars.minres;
                sys.Connection{2}.Mach = abs(pars.Mach);
                sys.Connection{2}.c = abs(pars.c);
                sys.Connection{2}.rho = 1;
                sys.Connection{2}.A = 1;
                pars = rmfield(pars,{'Mach','c'});
            end
            
            con = Block.readPort(pars,sys.Connection);
            sys = set_Connection(sys, con);
        end
        
        %% Set functions
        function sys = set.l(sys, l)
            if not(isequal(sys.l, l))
                sys.l = l;
                sys.uptodate = false;
            end
        end
        function sys = set.order(sys, order)
            if not(isequal(sys.order, order))
                if ((order<=3) && (0<=order))||(order==Inf)
                    sys.order = order;
                    sys.uptodate = false;
                else
                    warning(['Order out of range [1-3, Inf]:',num2str(order)])
                    sys.order = order;
                    sys.uptodate = false;
                end
            end
        end
        function sys = set.minres(sys, minres)
            if not(isequal(sys.minres, minres))
                sys.minres = minres;
                sys.uptodate = false;
            end
        end
        function sys = set.fMax(sys, fMax)
            if not(isequal(sys.fMax, fMax))
                sys.fMax = fMax;
                sys.uptodate = false;
            end
        end
        
        %% Get functions
        function N = get.N(sys)
            c = sys.Connection{1}.c;
            Mach = -sys.Connection{1}.Mach;
            lambdaMin = 1/sys.fMax*c*(Mach+1);
            dXmax = lambdaMin/sys.minres;
            N = ceil(sys.l/dXmax);
        end
        function dX = get.dX(sys)
            if sys.N>0
                dX = sys.l/sys.N;
            else
                dX=0;
            end
        end
        
        %% Mean values on interfaces
        function sys = set_Connection(sys, con)
            sys.Connection = Block.solveMean(con);
            if Block.checkPort(sys.Connection,AcBlock.Port)
                sys = update(sys);
            end
        end
        
        %% Declaration of Abstract functions
        function sys = update(sys)
            %% Check if system is uptodate
            if sys.uptodate
                return
            end
            sys= sys.clear();
            
            Mach = -sys.Connection{1}.Mach;
            c = sys.Connection{1}.c;
            rho = sys.Connection{1}.rho;
            u= Mach*c;
            
            % Duct resolution
            n = sys.N;
            dX = sys.dX;
            
            if sys.N==0
                % If duct is acoustically compact
                A=sparse(0,0);
                B=sparse(0,2);
                C=sparse(2,0);
                D=sparse([0 1; 1, 0]);
            else
                %% Finite difference coeffcients of upwind scheme
                % http://en.wikipedia.org/wiki/Upwind_scheme
                % https://en.wikipedia.org/wiki/Finite_difference_coefficient
                % all coefficients have negative sign compared to the reference, as they
                % are moved to the rhs of the equation.
                
                %% Discretization matrices / System Matrix
                % State vector does not contain f0 and gn, because they are
                % inputs to the system and therefore not part of state!
                % Opposed to that g0 and fn are outputs and therefore these
                % states exist.
                %       f1
                %       f2
                %  x =  ...
                %       fn=fd
                %       g0=gu
                %       g1
                %       ...
                %       gn-1
                
                %% Input is on the boundary and acting on the time derivative of the next
                % stencil by spatial derivative
                B = sparse(n+n,2);
                
                if (sys.order==1)||(n==1)
                    %First order
                    fnf = [-1,0]; ff = -(c+u)*Duct.getCoeff(dX,fnf);
                    fng = [0,1]; fg = (c-u)*Duct.getCoeff(dX,fng);
                    Af = sparse(1:n, 1:n, ff(fnf==0),n,n) + sparse(2:n, 1:n-1, ff(fnf==-1),n,n);
                    Ag = sparse(1:n, 1:n, fg(fng==0),n,n) + sparse(1:n-1, 2:n, fg(fng==1),n,n);
                    B(1,1) = ff(fnf==-1); % fu first input
                    B(n+n,2) = fg(fng==1); % gd second input
                elseif (sys.order==2)||(n==2)||(n==3)
                    %Second order
                    snf = [-2,-1,0]; sf = -(c+u)*Duct.getCoeff(dX,snf);
                    sng = [0,1,2]; sg = (c-u)*Duct.getCoeff(dX,sng);
                    % Boundary: move stencil to fit in domain
                    snfb = [-1,0,1]; sfb = -(c+u)*Duct.getCoeff(dX,snfb);
                    sngb = [-1,0,1];sgb = (c-u)*Duct.getCoeff(dX,sngb);
                    
                    Af = sparse(1:1, 1:1, sfb(snfb==0),n,n) +sparse(1,2,sfb(snfb==1),n,n)...
                        + sparse(2:n, 2:n, sf(snf==0),n,n) + sparse(2:n, 1:(n-1), sf(snf==-1),n,n)...
                        + sparse(3:n, 1:(n-2), sf(snf==-2),n,n);
                    B(1,1) = sfb(snfb==-1); % fu first input
                    B(2,1) = sf(snf==-2);
                    
                    Ag = sparse(n, n, sgb(sngb==0),n,n) + sparse(n, n-1, sgb(sngb==-1),n,n)...
                        + sparse(1:n-1, 1:n-1, sg(sng==0),n,n) + sparse(1:(n-1), 2:n, sg(sng==1),n,n)...
                        +sparse(1:(n-2), 3:n, sg(sng==2),n,n);
                    B(n+n,2) = sgb(sngb==1); % gd second input
                    B(n+n-1,2) = sg(sng==2); % gd second input
                elseif (sys.order==3)
                    % Third order
                    tnf = [1,0,-1,-2]; tf = -(c+u)*Duct.getCoeff(dX,tnf);
                    tng = [-1,0,1,2];  tg = (c-u)*Duct.getCoeff(dX,tng);
                    % Boundary: Input move stencil to fit in domain
                    tnfb = [2,1,0,-1];  tfb = -(c+u)*Duct.getCoeff(dX,tnfb);
                    tngb = [-2,-1,0,1]; tgb = (c-u)*Duct.getCoeff(dX,tngb);
                    % Boundary: Output move stencil to fit in domain
                    tnfbo = [-3,-2,-1,0];  tfbo = -(c+u)*Duct.getCoeff(dX,tnfbo);
                    tngbo = [0,1,2,3]; tgbo = (c-u)*Duct.getCoeff(dX,tngbo);
                    
                    Af = sparse(1, 1, tfb(tnfb==0),n,n) + sparse(1, 2, tfb(tnfb==1),n,n) + sparse(1, 3, tfb(tnfb==2),n,n)... % first 2 stencils input scheme
                        +sparse(2:n-1, 2:n-1, tf(tnf==0),n,n) + sparse(2:n-1, 1:(n-2), tf(tnf==-1),n,n)... % intermediate stencils
                        +sparse(3:n-1, 1:(n-3), tf(tnf==-2),n,n) + sparse(2:n-1, 3:n, tf(tnf==1),n,n)...
                        +sparse(n, n, tfbo(tnfbo==0),n,n) + sparse(n, n-1, tfbo(tnfbo==-1),n,n)... % last stencil output scheme
                        +sparse(n, n-2, tfbo(tnfbo==-2),n,n) + sparse(n, n-3, tfbo(tnfbo==-3),n,n);
                    B(1,1) = tfb(tnfb==-1); % fu first input
                    B(2,1) = tf(tnf==-2); % fu first input
                    
                    Ag = sparse(n:n, n:n, tgb(tngb==0),n,n) + sparse(n, n-1, tgb(tngb==-1),n,n)+ sparse(n, n-2, tgb(tngb==-2),n,n)...% last 2 stencils input scheme
                        +sparse(2:n-1, 2:n-1, tg(tng==0),n,n) + sparse(2:(n-1), 3:n, tg(tng==1),n,n)...% intermediate stencils
                        +sparse(2:(n-2), 4:n, tg(tng==2),n,n) + sparse(2:n-1, 1:n-2, tg(tng==-1),n,n)...
                        +sparse(1, 1, tgbo(tngbo==0),n,n) + sparse(1, 2, tgbo(tngbo==1),n,n)... % first stencil output schenme
                        +sparse(1, 3, tgbo(tngbo==2),n,n) + sparse(1, 4, tgbo(tngbo==3),n,n);
                    B(n+n,2) = tgb(tngb==1); % gd second input
                    B(n+n-1,2) = tg(tng==2); % gd second input
                else
                    % Maximum order
                    Af = zeros(n,n); Ag = zeros(n,n); B=full(B);
                    for i = 1: n
                        nf = (-i):(n-i); f = Duct.getCoeff(dX,nf);
                        ng = (-i+1):(n-i+1); g = Duct.getCoeff(dX,ng);
                        Af(i,:) = -(c+u)*f(2:end);
                        Ag(i,:) = (c-u)*g(1:end-1);
                        B(i,1) = -(c+u)*f(1);
                        B(n+i,2) = (c-u)*g(end);
                    end
                    Af = sparse(Af); Ag = sparse(Ag); B = sparse(B);
                end
                
                A = blkdiag(Af,Ag);
                
                
                %% Output is directly the value on the respective stencils
                N = n+n;
                
                C = sparse(2+n-1+n-1, n+n);
                
                C(1,size(Af,1)+1) = 1; % gu first output
                C(2,size(Af,1)) = 1;   % fd second output
                
                fint = sparse(1+2*(1:n-1), (1:n-1), 1, N, N);
                C = C + fint;
                
                gint = sparse(2+2*(1:n-1), 1+n+(1:n-1), 1, N, N);
                C = C + gint;
                
                %% Compute sensor outputs
                % Limit the sensor positions
                if any(sys.sensorPositions>sys.l)||any(sys.sensorPositions<0)
                    error([sys.Name,': Sensor positions out of duct.'])
                end
                
                % Determine sensor indices from position and adjacent stencils
                idXSense = sys.sensorPositions/sys.dX;
                idXLow = floor(idXSense);
                idXHigh = idXLow+1;
                % Interpolation factor
                alpha = idXSense-idXLow;
                % Limit sensor interpolation indices to stencils that are
                % entirely inside the duct
                idXLow(idXLow==0) = idXLow(idXLow==0)+1;
                idXHigh(idXHigh==n) = idXHigh(idXHigh==n)-1;
                
                % Offset between states corresponding to f and g in state
                % vector x
                offsetg = n+1;
                % Compute and append outputs
                Csense_f = sparse(1:length(idXHigh),idXHigh, alpha, length(idXHigh),N)...
                    + sparse(1:length(idXLow),idXLow, (1-alpha), length(idXLow),N);
                Csense_g = sparse(1:length(idXHigh),idXHigh+offsetg, alpha, length(idXHigh),N)...
                    + sparse(1:length(idXLow),idXLow+offsetg, (1-alpha), length(idXLow),N);
                C = [C;Csense_f;Csense_g];
                
                D = [];
            end
            
            %% Populate continuous time system matrices
            sys = sys.updatesss(sss(A,B,C,D,[],0));
            
            id = num2str(sys.Connection{1}.idx,'%02d');
            sys.StateGroup.(char(['f_',id])) = 1:(sys.n/2)-1;
            sys.StateGroup.(char(['g_',id])) = (sys.n/2)+2:sys.n;
            
            %% Give names to sensor outputs
            sys.OutputGroup.Sensor = [];
            for i= 1: length(sys.sensorPositions)
                sys.y{2*n+i} = ['f_',sys.Name,'@',num2str(sys.sensorPositions(i)','%G')];
                sys.y{2*n+i+length(idXLow)} = ['g_',sys.Name,'@',num2str(sys.sensorPositions(i)','%G')];
                sys.OutputGroup.Sensor = [sys.OutputGroup.Sensor, 2*n+i, 2*n+i+length(idXLow)];
            end
            
            % Give names to the ports and create in- and output groups
            sys = twoport(sys);
            
            %% Give names to internal acoustic states outputs
            format =['%0' ,num2str(ceil(log10(2*sys.N-2))),'d' ];
            for i = 3: 2*sys.N
                if mod(i,2)
                    % odd
                    sys.y{i} = [num2str(sys.Connection{1}.idx,'%02d'),'f','_', sys.Name,'_',num2str(floor((i-1)/2),format)];
                    sys.OutputGroup.f = [sys.OutputGroup.f,i];
                else
                    % even
                    sys.y{i} = [num2str(sys.Connection{1}.idx,'%02d'),'g','_', sys.Name,'_',num2str(floor((i-1)/2),format)];
                    sys.OutputGroup.g = [sys.OutputGroup.g,i];
                end
            end
            
            %% Populate plotting quantities
            if sys.dX>0
                sys.state.x = dX:dX:sys.l;
            else
                sys.state.x = eps;
            end
            idx = linspace(0,1,length(sys.state.x)+1);
            sys.state.idx = idx(2:end);
            sys.state.rho = ones(1,length(sys.state.x))*rho;
            sys.state.c = ones(1,length(sys.state.x))*c;
            sys.state.Mach = ones(1,length(sys.state.x))*Mach;
            sys.state.A = ones(1,length(sys.state.x))*sys.Connection{1}.A;
            
            sys.uptodate = true;
        end
        
        %% Determine time step according to CFL number for time simulation
        function Ts = CFLtoTs(sys, cfl)
            c = sys.Connection{1}.c;
            Mach = -sys.Connection{1}.Mach;
            u= Mach*c;
            
            Ts = cfl*sys.dX/(u+c);
        end
        
    end
    
    methods(Static)
        %% Compute Coefficients of upwind scheme, given a stencil n
        % e.g. third order stencil: n = [1,0,-1,-2]
        % https://en.wikipedia.org/wiki/Finite_difference_coefficient
        % Documentation in Duct_symbolic.m
        function an = getCoeff(dX, n)
            An = (zeros(length(n)))*dX; % Cast for symbolic dX
            % Expand to maximum order i of stencil length(n)-1
            for i=0:length(n)-1
                % Coefficient matrix of Taylor series expansion
                An(i+1,:) = (n*dX).^i/factorial(i);
            end
            sol = zeros(1,length(n))';
            sol(2,1) = 1;
            an = An\sol;
        end
    end
    
end