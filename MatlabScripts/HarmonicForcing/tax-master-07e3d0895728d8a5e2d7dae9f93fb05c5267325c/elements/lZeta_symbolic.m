% Documentation of lZeta class

% original lZeta from taX implementation
clear
syms s lred leff c zeta kappa_pi kappa_mi kappa_pj kappa_mj Machi Machj ai aj

port_in = 1;
port_out= 2;

output = [2,3];
input = [1,4];

% ikl=1i*omega*l./c;
ikl=s*lred./c  ;
ztp=zeta+1;

sys_matr(2*port_in,2*port_in-1)= (ikl-Machi).*kappa_pi-1;    % x fi
sys_matr(2*port_in,2*port_in)  =(ikl-Machi).*kappa_mi-1;     % x gi
sys_matr(2*port_in,2*port_out-1)=1+ Machj*kappa_pj*ztp;          % x fj
sys_matr(2*port_in,2*port_out)=1+ Machj*kappa_mj*ztp;            % x gj

sys_matr(2*port_out-1,2*port_in-1)=ai*(Machi + kappa_pi);        % x fi
sys_matr(2*port_out-1,2*port_in)= ai*(Machi + kappa_mi);         % x gi
sys_matr(2*port_out-1,2*port_out-1)= -aj*(Machj + kappa_pj);         % x fj
sys_matr(2*port_out-1,2*port_out)=-aj*(Machj + kappa_mj);            % x gj

% Old Area change code:
% sys_matr(2*port_in,2*port_in-1,:)= 1+ Machi*kappa_pi;                % x fi
% sys_matr(2*port_in,2*port_in,:)  =1+ Machi*kappa_mi;                 % x gi
% sys_matr(2*port_in,2*port_out-1,:)=-1*(1+ Machj*kappa_pj*(1+zeta));  % x fj
% sys_matr(2*port_in,2*port_out,:)=-1*(1+ Machj*kappa_mj*(1+zeta));    % x gj
% 
% sys_matr(2*port_out-1,2*port_in-1,:)=ai*(Machi + kappa_pi);          % x fi
% sys_matr(2*port_out-1,2*port_in,:)= ai*(Machi + kappa_mi);           % x gi
% sys_matr(2*port_out-1,2*port_out-1,:)= -aj*(Machj + kappa_pj);       % x fj
% sys_matr(2*port_out-1,2*port_out,:)=-aj*(Machj + kappa_mj);          % x gj

A = sys_matr(output,output);
B = sys_matr(output,input);

localMatrix = simplify(-inv(A)*B);

% Hardcoded result for cst element:
Matrix(1,:) = [ -(Machi*ai*c - Machj*aj*c + ai*c*kappa_pi - aj*c*kappa_pj + Machi*Machj*ai*c*kappa_pj - Machi*Machj*aj*c*kappa_pi + Machj*ai*c*kappa_pi*kappa_pj - Machi*aj*c*kappa_pi*kappa_pj + Machj*aj*kappa_pi*lred*s + aj*kappa_pi*kappa_pj*lred*s + Machi*Machj*ai*c*kappa_pj*zeta + Machj*ai*c*kappa_pi*kappa_pj*zeta)/(Machi*ai*c - Machj*aj*c + ai*c*kappa_mi - aj*c*kappa_pj + Machi*Machj*ai*c*kappa_pj - Machi*Machj*aj*c*kappa_mi + Machj*ai*c*kappa_mi*kappa_pj - Machi*aj*c*kappa_mi*kappa_pj + Machj*aj*kappa_mi*lred*s + aj*kappa_mi*kappa_pj*lred*s + Machi*Machj*ai*c*kappa_pj*zeta + Machj*ai*c*kappa_mi*kappa_pj*zeta),                                                                                                                                                                                                                                               -(aj*c*(kappa_mj - kappa_pj)*(Machj^2*zeta + Machj^2 - 1))/(Machi*ai*c - Machj*aj*c + ai*c*kappa_mi - aj*c*kappa_pj + Machi*Machj*ai*c*kappa_pj - Machi*Machj*aj*c*kappa_mi + Machj*ai*c*kappa_mi*kappa_pj - Machi*aj*c*kappa_mi*kappa_pj + Machj*aj*kappa_mi*lred*s + aj*kappa_mi*kappa_pj*lred*s + Machi*Machj*ai*c*kappa_pj*zeta + Machj*ai*c*kappa_mi*kappa_pj*zeta)];
Matrix(2,:) = [                                                                                                                                                                                                                                                 (ai*(kappa_mi - kappa_pi)*(- c*Machi^2 + lred*s*Machi + c))/(Machi*ai*c - Machj*aj*c + ai*c*kappa_mi - aj*c*kappa_pj + Machi*Machj*ai*c*kappa_pj - Machi*Machj*aj*c*kappa_mi + Machj*ai*c*kappa_mi*kappa_pj - Machi*aj*c*kappa_mi*kappa_pj + Machj*aj*kappa_mi*lred*s + aj*kappa_mi*kappa_pj*lred*s + Machi*Machj*ai*c*kappa_pj*zeta + Machj*ai*c*kappa_mi*kappa_pj*zeta), -(Machi*ai*c - Machj*aj*c + ai*c*kappa_mi - aj*c*kappa_mj + Machi*Machj*ai*c*kappa_mj - Machi*Machj*aj*c*kappa_mi + Machj*ai*c*kappa_mi*kappa_mj - Machi*aj*c*kappa_mi*kappa_mj + Machj*aj*kappa_mi*lred*s + aj*kappa_mi*kappa_mj*lred*s + Machi*Machj*ai*c*kappa_mj*zeta + Machj*ai*c*kappa_mi*kappa_mj*zeta)/(Machi*ai*c - Machj*aj*c + ai*c*kappa_mi - aj*c*kappa_pj + Machi*Machj*ai*c*kappa_pj - Machi*Machj*aj*c*kappa_mi + Machj*ai*c*kappa_mi*kappa_pj - Machi*aj*c*kappa_mi*kappa_pj + Machj*aj*kappa_mi*lred*s + aj*kappa_mi*kappa_pj*lred*s + Machi*Machj*ai*c*kappa_pj*zeta + Machj*ai*c*kappa_mi*kappa_pj*zeta)];

% Transfermatrix according to polifke polif11a

T = [1         , s*leff/c - zeta*Machi;...
     -s*lred/c , ai/aj                ];
 
 S = simplify(TtoS(T));
 
 Matrix2(1,:) = [                                                 1 - (2*Machj + (2*lred*s)/c + 2)/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1),                                        2/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1)];
 Matrix2(2,:) = [ ((2*ai)/aj - 2*(Machj + (lred*s)/c)*(Machi*(zeta + ai^2/aj^2 - 1) + (leff*s)/c))/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1), 1 - (2*Machj + (2*ai)/aj + (2*lred*s)/c)/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1)];

%% Possible extension: use result from Gentemann Polifke Paper 2003, see
% asana
% 
% clear
syms zeta ai aj Machi Machj leff lred c s 

T2= [1, (1-zeta-(ai/aj)^2)*Machi - s*leff/c; ...
    -s*lred/c - Machj,  ai/aj];

S2 = simplify(TtoS(T2));

% Hardcoded result for cst element:
Matrix3(1,:) = [                                                 1 - (2*Machj + (2*lred*s)/c + 2)/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1),                                                                             2/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1)];
Matrix3(2,:) = [ ((2*ai)/aj - 2*(Machj + (lred*s)/c)*(Machi*(zeta + ai^2/aj^2 - 1) + (leff*s)/c))/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1), -(Machj - Machi*(zeta + ai^2/aj^2 - 1) + ai/aj - (leff*s)/c + (lred*s)/c - 1)/(Machj + Machi*(zeta + ai^2/aj^2 - 1) + ai/aj + (leff*s)/c + (lred*s)/c + 1)];
 
zeta =0;
leff = 0;
lred = 0;
% c = 0;
% Machi = 0;
% Machj = 0;
ai= aj; % Zero area jump
% aj=1;

AreaJump = simplify(eval(Matrix3))

% AreaJump(1,:) = [ (ai - aj)/(ai + aj),     (2*aj)/(ai + aj)]
% AreaJump(2,:) = [    (2*ai)/(ai + aj), -(ai - aj)/(ai + aj)]