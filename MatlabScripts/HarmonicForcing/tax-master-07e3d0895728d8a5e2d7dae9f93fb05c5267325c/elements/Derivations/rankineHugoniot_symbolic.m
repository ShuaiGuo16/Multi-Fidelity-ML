%  Documentation: Rankine Hugoniot jump equations solved symolically
clear
clc
close all

syms S rho_u c_u rho_d c_d T_d T_u M_d M_u gamma u_u FTF

%% Full equations
% Transfermatrix Rankine Hugoniot with external heat release
Trh = [ (rho_u*c_u)/(rho_d*c_d), -(T_d/T_u-1) *M_d , -(T_d/T_u -1)*M_d*u_u ;...
      -gamma*(T_d/T_u-1)*M_u ,                 1 ,     (T_d/T_u -1)*u_u ];

  
%%%%%%%%%%%%%%% Validation:
% Rankine hugoniot reference directly upstream flame and Transfermatrix
% formulation
% Validated against Polifke 2011 Low-Order Analysis Tools for Aero- and Thermo-Acoustic Instabilities
Trhru(:,1) = Trh(:,1);
Trhru(:,2) = Trh(:,2)+ Trh(:,3)*FTF/u_u; % FTF/u_u = Q'/Q
pretty(Trhru);

[Srhrut, Omegarhrut, mrhru]= transformTtoS(eval(Trhru));
% pretty(simple(Srhrut));
% Srhrut2 = simple (Srhrut*Omegarhru);
%%%%%%%%%%%%%%%

% Transformation to Scattering matrix with external heat release
[Srht, Omega, m] = transformTtoS(Trh(:,1:2));
Srht(:,3) = m*Trh(:,3);

% Assembly: heat release reference directly upstream
Srhtru = Srht(:,1:2);
Srhtru(:,3) = Srht(:,3)*FTF/u_u;
Lhsrhtru = [1 + Srhtru(1,3), 0;...
        Srhtru(2,3), 1];
Rhsrhtru = [Srhtru(1,1) + Srhtru(1,3), Srhtru(1,2);...
       Srhtru(2,1) + Srhtru(2,3), Srhtru(2,2)];
Srhtruc = factor(inv(Lhsrhtru)*Rhsrhtru);
% Crosscheck: set reference before and after transformation: Srhtru = Srhrut
pretty(simple(Srhtruc-Srhrut)) % success


% Simplifications for crosscheck with simplified version
M_u = 0;
M_d = 0;
xi = (rho_u*c_u)/(rho_d*c_d);
theta = (T_d/T_u-1);

disp('Trh - Transfermatrix of rankine hugoniot simplified:')
Trhs = eval(Trh)
Trhs = feval(symengine,'subsex',Trhs,[char(xi) '=xi']);
Trhs = feval(symengine,'subsex',Trhs,[char(theta) '= theta']);
pretty(simple(Trhs));

disp('Srhtru - Scattering matrix of rankine hugoniot transformed reference upstream simplified:')
Srhtrus = eval(Srhtru);
Srhtrus= feval(symengine,'subsex',Srhtrus,[char(xi) '=xi']);
Srhtrus= feval(symengine,'subsex',Srhtrus,[char(theta) '= theta']);
pretty(simple(Srhtrus));

disp('Omegarhrut - Scattering matrix of rankine hugoniot transformed reference upstream simplified:')
Omegarhruts = eval(Omegarhrut);
Omegarhruts= feval(symengine,'subsex',Omegarhruts,[char(xi) '=xi']);
Omegarhruts= feval(symengine,'subsex',Omegarhruts,[char(theta) '= theta']);
pretty(simple(Omegarhruts));


%% Simplified version
syms xi theta
% simplified rankine hugoniot transfermatrix
Tsrh = [ xi, 0, 0;
        0, 1, theta*u_u];
 
[Ssrht, Omegasrht, m] = transformTtoS(Tsrh(:,1:2));
Ssrht(:,3) = m*Tsrh(:,3);
pretty(simple(Ssrht))

% Connect simplified system reference position directly upstream
% Validation: Transfermatrix interconnected and transformed:
Tsrhru(:,1) = Tsrh(:,1);
Tsrhru(:,2) = Tsrh(:,2)+ Tsrh(:,3)*FTF/u_u; % FTF/u_u = Q'/Q
[Ssrhrut, Omegasrhrut, mrhru]= transformTtoS(eval(Tsrhru));
% Omegarhrut_test = Tsrhru(1,1) - Tsrhru(1,2) - Tsrhru(2,1) + Tsrhru(2,2);

% Corresponding scatteringmatrix interconnected and solved:
Ssrhtru(:,1:2) = Ssrht(:,1:2);
Ssrhtru(:,3) = Ssrht(:,3)*FTF/u_u;
Lhs = [1 + Ssrhtru(1,3), 0;...
        Ssrhtru(2,3), 1];
Rhs = [Ssrhtru(1,1) + Ssrhtru(1,3), Ssrhtru(1,2);...
       Ssrhtru(2,1) + Ssrhtru(2,3), Ssrhtru(2,2)];

Ssrhtru = factor(inv(Lhs)*Rhs);
disp('Ssrhtru - Scatter simplified rh, transformed, ref upstream:')
pretty(Ssrhtru)
% Normalize with omega:


% Determinant of system analysis - this is related to potentiality
% disp('det(S1)')
% pretty((det(S1)))
% factor(S1(1,1)*S1(2,2))
% factor(S1(1,2)*S1(2,1))
% Determinant check
% factor(S1(1,1)*S1(2,2)-S1(1,2)*S1(2,1));

% pretty(simple(inv(Lhs)));

Omega = simple(det(Lhs));
pretty(Omega)

% Case 2: Duct section and area jump inbetween
% todo
 
%% Successfully test the simplified version of the Matrices against each other
% Simplifications
% M_u = 0;
% M_d = 0;
% Stest = simple(eval(S));
% pretty(Stest)

 xi = (rho_u*c_u)/(rho_d*c_d);
 theta = (T_d/T_u-1);
%  Stest2 = simple(eval(Ss));
%  pretty(Stest2)

%% Remove common denominator omega from matrix
Ssrhtru = Omegasrhrut*Ssrhtru;

%% Latex export
pathToLatex = '/home/thomas/Dropbox/Paper FlameFeedback/';

symb2latex(simple(eval(Ssrht)), [pathToLatex,'Ssrht.tex'])
symb2latex(simple(Ssrhtru), [pathToLatex,'Ssrhtru.tex'])
symb2latex(Omegasrhrut, [pathToLatex,'Omegasrhrut.tex'])

% input and output vectors
syms f_u g_u f_d g_d
Sin= [f_u; g_d];
Sout =  [g_u; f_d];
symb2latex(Sin, [pathToLatex,'Sin.tex'])
symb2latex(Sout, [pathToLatex,'Sout.tex'])
symb2latex(Sin.', [pathToLatex,'Sint.tex'])
symb2latex(Sout.', [pathToLatex,'Soutt.tex'])
symb2latex(S, [pathToLatex,'S.tex'])

% symb2latex(Tin, [pathToLatex,'Tin.tex'])
% symb2latex(Tout, [pathToLatex,'Tout.tex'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Case2: duct section and area jump
% Scattering matrix of a duct section
syms D12 D21
Sd = [0 D12; D21 0]

% Transfermatrix of area jump
% Transfermatrix according to polifke polif11a
syms s lred leff c zeta Machi Machj ai aj


Machi =0;
Machj =0;
lred =0;
% leff =0;

Tb = [ 1         , s*leff/c - zeta*Machi ;...
    -s*lred/c , ai/aj                ];

alpha = ai/aj;
Tb = eval(Tb);


Sb = simple(transformTtoS(Tb))
%  
%  Matrix2(1,:) = [                                                 1 - (2*Machj + (2*lred*s)/c + 2)/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1),                                        2/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1)];
%  Matrix2(2,:) = [ ((2*ai)/aj - 2*(Machj + (lred*s)/c)*(Machi*(zeta + ai^2/aj^2 - 1) + (leff*s)/c))/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1), 1 - (2*Machj + (2*ai)/aj + (2*lred*s)/c)/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1)];

Tbf = Tsrh(:,1:2)*Tb

Tbf(:,3) = Tsrh(:,3)

[Ssbf, Omegasbf, m] = transformTtoS(Tbf(:,1:2));
Ssbf(:,3) = m*Tbf(:,3);
pretty(simple(Ssbf))

% Calculate g_ref as a function of g_u vice versa
%g_ref=G*g_u
G= Sb(2,1)*Sd(2,1)
