function [localMatrix, localRhs, localC] = curvedDuct(omega, mode, Block, Connection)
% curvedDuct(port_in_S,l,n,d_vector,a_vector)

% CURVED_DUCT
% curved duct models a continuous area change by discretizing the duct as
% a series of abrupt area changes and simple ducts.
%
% Specific input arguments at Simulink graphical interface
% l- length of the curved duct
% n- number of pairs of area_changes/ simple_ducts used in the
%    discretization of the curved duct
% d(x)- average cross section diameter, function of axial coordinate x.
%       Code in Initialization of element Mask (Simulink),
%       (use default value of 1 if not interested in azimuthal modes)
% a(x)- cross sectional area, function of axial coordinate x.
%       Code in Initialization of element Mask (Simulink)
%
% (c) Copyright 2010 tdTUM. All Rights Reserved.

port_in = 1;
port_out =2;

rank_omega =  length(omega);
tfm(1,1,:) =ones(1,rank_omega);       % init. of tfm as identity matrix[2x2xrank_omega]
tfm(2,2,:) =ones(1,rank_omega);
%----------------------------------------
% disp(Connection)
Machi = Connection{1}.Mach;
Di = Connection{1}.D;
ai = Connection{1,1}.a;
c = Connection{1}.c;
rho = Connection{1}.rho;
Machj = Connection{2}.Mach;
Dj = Connection{2}.D;
aj = Connection{2}.a;

l= Block.l;
n= eval(Block.n{1,1});

%Construct the area vector
xx = l*((1:n)-0.5)/(n); %discretized points
a_vector = zeros(1,n+2);
for kk=1:n
    %Evaluate the area function given in terms of x
    x = xx(kk);
    eq = eval(Block.surface_poly{1,1});
    if ischar(eq)
        eq = eq(2:end-1);
        a_vector(kk+1)= eval(eq);
    else
        a_vector(kk+1)= eq;
    end
end
a_vector(1) = ai;
a_vector(end) = aj;

%Construct the diameter vector
d_vector = zeros(1,n+2);
d_vector(1) = Di;
d_vector(end) = Dj;
switch Block.d_Auto{1,1}
    case 'on' %calculate diameter from area
        d_vector=sqrt(1.*a_vector./pi);
    case 'off' %calculate diameter from specified equation
        for kk = 1:n
            x = xx(kk);
            d_vector(kk+1) = eval(Block.d_polyin{1,1});
        end
end


%------------------------------------------------------------------------
% discretization of curved duct of length l in n sections,
% results in n+2 different Diameters/ areas, n for the curved duct plus
% 1 for the inlet and 1 for the outlet (kk+1 assignements)
for kk = 1:n+1
    Di=d_vector(kk);
    Dj=d_vector(kk+1);
    ai=a_vector(kk);
    aj=a_vector(kk+1);
    Machj = double((ai/aj)*Machi);
    
    [kx_pi,kx_mi,kappa_pi,kappa_mi]=kx_and_kappa(omega,mode,Machi,c,Di);
    [kx_pj,kx_mj,kappa_pj,kappa_mj]=kx_and_kappa(omega,mode,Machj,c,Dj);
    
    
    % a) Abrupt area changes {fj,gj}=[tfm]{fi,gi}, with [tfm]=X.-Y^-1
    
    zeta=0  ; % area change without losses assuming the discretization of a smooth duct
    elem_matrix(1,1,:) = 1+ Machi*kappa_pi;         % x fi
    elem_matrix(1,2,:) = 1+ Machi*kappa_mi;         % x gi
    elem_matrix(2,1,:) = ai*(Machi + kappa_pi);     % x fi
    elem_matrix(2,2,:) = ai*(Machi + kappa_mi);     % x gi
    
    for k=1:rank_omega
        tfm(:,:,k) = elem_matrix(:,:,k)*tfm(:,:,k);
    end
    
    % -Y^-1, [2x2xrank_omega]
    % =-1*1/(ad-cb)*[(d,-b),(-c,a)], 2x2 matrix inversion
    ad_cb=(1+ Machj*kappa_pj*(1+zeta)).*(aj*(Machj + kappa_mj))-(1+ Machj*kappa_mj*(1+zeta)).*(aj*(Machj + kappa_pj));
    elem_matrix(1,1,:) = (-aj*(Machj + kappa_mj))./ad_cb;         % -1*d/ad-cb
    elem_matrix(1,2,:) = (1+ Machj*kappa_mj*(1+zeta))./ad_cb;     % -1*- b/ad-cb
    elem_matrix(2,1,:) = aj*(Machj + kappa_pj)./ad_cb;            % -1*- c/ad-cb
    elem_matrix(2,2,:) = -1*(1+ Machj*kappa_pj*(1+zeta))./ad_cb;  % -1*a/ad-cb
    
    % transfer matrix of Area change
    % [tfmAC], -Y^-1.X, [2x2xrank_omega]
    for k=1:rank_omega
        tfm(:,:,k) = elem_matrix(:,:,k)*tfm(:,:,k);
    end
    
    
    % b) Simple ducts, each of length l/n
    % transfer matrix of simple duct
    % [tfmSD], -Y^-1.X=-1.X
    
    % -X
    if kk~=n+1
        elem_matrix(1,1,:) = -exp(-1i.*kx_pj*(l/n));     % x fi
        elem_matrix(2,2,:) = -exp(-1i.*kx_mj*(l/n));     % x gi
        elem_matrix(1,2,:) = 0;                         % x fi
        elem_matrix(2,1,:) = 0;                         % x gi
        
        
        % [tfmACSD]=[tfmSD][tfmAC]
        for k=1:rank_omega
            tfm(:,:,k) = elem_matrix(:,:,k)*tfm(:,:,k);
        end
        
    end
    
    % update the Mach number
    Machi=Machj;
    
end % n+1 reached


%------------------------------------------------
% Transfer matrix for the curved duct element

sys_matr(2*port_in,2*port_in-1,:)=tfm(1,1,:);         % x fi
sys_matr(2*port_in,2*port_in,:)=tfm(1,2,:);           % x gi
sys_matr(2*port_in,2*port_out-1,:)=1;                 % x fj

sys_matr(2*port_out-1,2*port_in-1,:)=tfm(2,1,:);      % x fi
sys_matr(2*port_out-1,2*port_in,:)= tfm(2,2,:);       % x gi
sys_matr(2*port_out-1,2*port_out,:)=1;                % x gj

%------------------------------------------------

rhs(2*port_in,1) = 0;
rhs(2*port_out-1,1) = 0;

[localMatrix, localRhs] = transformLegacyToS(sys_matr, rhs);

localMatrix = num2cell(localMatrix,3);
localRhs = num2cell(localRhs,2);
localC = {1;1};

end