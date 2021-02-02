function [localMatrix localRhs localC] = lumpedVolume(omega, mode, Block, Connection)
%LUMPEDMASS 
% 
% (c) Copyright 2010 tdTUM. All Rights Reserved.

port_in = 1;
port_out= 2;

Mach = Connection{1}.Mach;
D = Connection{1}.D;
a = Connection{1}.a;
c = Connection{1}.c;
rho = Connection{1}.rho;

Leq = eval(cell2mat(Block.Leq));
Veq = eval(cell2mat(Block.Veq));
Flag = (cell2mat(Block.Flag));

%-----------------------------------------------------------
[kx_pi,kx_mi,kappa_pi,kappa_mi]=kx_and_kappa(omega,mode,Mach,c,D);
[kx_pj,kx_mj,kappa_pj,kappa_mj]=kx_and_kappa(omega,mode,Mach,c,D);

switch Flag
 case 'Equivalent Length'
     %length
 case 'Volume'
     Leq = Veq./a;
end

ikl = 1i*omega*Leq./c;

%momentum equation:
sys_matr(2*port_in,2*port_in-1,:) =  (1 + Mach*kappa_pi);           % x fi
sys_matr(2*port_in,2*port_in,:)   =  (1 + Mach*kappa_mi);           % x gi
sys_matr(2*port_in,2*port_out-1,:)= -(1 + Mach*kappa_pj);           % x fj
sys_matr(2*port_in,2*port_out,:)  = -(1 + Mach*kappa_mj);           % x gj
 
%volume flux equation
sys_matr(2*port_out-1,2*port_in-1,:) =  kappa_pi - Mach - ikl.*(1 + Mach*kappa_pi); % x fi
sys_matr(2*port_out-1,2*port_in,:)   =  kappa_mi - Mach - ikl.*(1 + Mach*kappa_mi); % x gi
sys_matr(2*port_out-1,2*port_out-1,:)= -kappa_pj - Mach;             % x fj
sys_matr(2*port_out-1,2*port_out,:)  = -kappa_mj - Mach;             % x gj

rhs(2*port_in,1) = 0; 
rhs(2*port_out-1,1) = 0;

[localMatrix, localRhs] = transformLegacyToS(sys_matr, rhs);

localMatrix = num2cell(localMatrix,3);
localRhs = num2cell(localRhs,2);
localC = {1;1};