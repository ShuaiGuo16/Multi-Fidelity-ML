function [sys] = triJunction_21(Block, Connection)
% TRIJUNCTION21 
% 
% (c) Copyright 2010 tdTUM. All Rights Reserved.

error('Old file')

port_in1=1;
port_in2=2;
port_out=3;

output = [0 1 0 1 1 0];
input = ~output;

zetai = eval(cell2mat(Block.zetai));
zetaj = eval(cell2mat(Block.zetaj));
ak=eval(cell2mat(Block.ak));

Machi = Connection{1}.Mach;
Di = Connection{1}.D;
ai = Connection{1}.a;
ci = Connection{1}.c;
rhoi= Connection{1}.rho;

Machj = Connection{2}.Mach;
Dj = Connection{2}.D;
aj = Connection{2}.a;
cj = Connection{2}.c;
rhoj= Connection{2}.rho;

Dk = Connection{3}.D;
ck = eval(cell2mat(Block.c));
rhok=eval(cell2mat(Block.rho));
Machk=(Machi*ci*ai*rhoi+Machj*cj*aj*rhoj)/(rhok*ck*ak);
 
%----------------------------------------------
omega=1;
mode=0;
    [kx_pi,kx_mi,kappa_pi,kappa_mi] = kx_and_kappa(omega,mode,Machi,ci,Di);
    [kx_pj,kx_mj,kappa_pj,kappa_mj] = kx_and_kappa(omega,mode,Machj,cj,Dj);
    [kx_pk,kx_mk,kappa_pk,kappa_mk] = kx_and_kappa(omega,mode,Machk,ck,Dk);
%----------------------------------------------

    sys_matr(2*port_in1,2*port_in1-1,:)= 1+ Machi*kappa_pi*(1+zetai);
    sys_matr(2*port_in1,2*port_in1,:)=1+ Machi*kappa_mi*(1+zetai);

    sys_matr(2*port_out-1,2*port_in1-1,:)=ai*(Machi + kappa_pi);
    sys_matr(2*port_out-1,2*port_in1,:)= ai*(Machi + kappa_mi);


    sys_matr(2*port_in2,2*port_in2-1,:)=1+ Machj*kappa_pj*(1+zetaj);
    sys_matr(2*port_in2,2*port_in2,:)=1+ Machj*kappa_mj*(1+zetaj);

    sys_matr(2*port_out-1,2*port_in2-1,:)= aj*(Machj + kappa_pj);
    sys_matr(2*port_out-1,2*port_in2,:)=aj*(Machj + kappa_mj);

    sys_matr(2*port_in1,2*port_out-1,:)=-(1+ Machk*kappa_pk);
    sys_matr(2*port_in1,2*port_out,:)=-(1+ Machk*kappa_mk);

    sys_matr(2*port_in2,2*port_out-1,:)=-(1+ Machk*kappa_pk);
    sys_matr(2*port_in2,2*port_out,:)=-(1+ Machk*kappa_mk);

    sys_matr(2*port_out-1,2*port_out-1,:)= -ak*(Machk + kappa_pk);
    sys_matr(2*port_out-1,2*port_out,:)=-ak*(Machk + kappa_mk);
   
    
    sys_matr(end+1,:) = 0;

% Coefficients for outputs
A = sys_matr(find(output),find(output),:);
B = sys_matr(find(output),find(input),:);

localMatrix = -inv(A)*B;


sys = ss(localMatrix);

sys.OutputGroup.Acoustic = 1:length(sys.y);
sys.InputGroup.Acoustic = 1:length(sys.u);