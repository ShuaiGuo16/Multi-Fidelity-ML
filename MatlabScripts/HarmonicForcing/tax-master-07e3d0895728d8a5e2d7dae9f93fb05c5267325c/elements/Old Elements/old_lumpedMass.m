function [localMatrix localRhs localC] = lumpedMass(omega, mode, Block, Connection)
% written by R. Mueller, IfTA GmbH
% based on LZETA element
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
meq = eval(cell2mat(Block.meq));
Flag = cell2mat(Block.Flag);

%-------------------------------------------------------------
[kx_pi,kx_mi,kappa_pi,kappa_mi]=kx_and_kappa(omega,mode,Mach,c,D);
[kx_pj,kx_mj,kappa_pj,kappa_mj]=kx_and_kappa(omega,mode,Mach,c,D);

switch Flag
    case 'Equivalent length'
       % length
    case 'Volume'
       Leq = Veq./a;
    case 'Mass'
       Veq = meq/rho;
       Leq = Veq./a;
    case 'Unflanged correction' %End correction L/Dh according to Levine and Schwinger
       Leq = 0.6133*sqrt(a/pi);
    case 'Flanged correction'
       Leq = 0.82159*sqrt(a/pi);
end    

ikl = 1i*omega*Leq./c;

%momentum equation:
sys_matr(2*port_in,2*port_in-1,:) = (ikl-Mach).*kappa_pi - 1;  % x fi   
sys_matr(2*port_in,2*port_in,:)   = (ikl-Mach).*kappa_mi - 1;  % x gi
sys_matr(2*port_in,2*port_out-1,:)=        Mach*kappa_pj + 1;  % x fj 
sys_matr(2*port_in,2*port_out,:)  =        Mach*kappa_mj + 1;  % x gj

%volume flux equation:
sys_matr(2*port_out-1,2*port_in-1,:) =  a*(Mach + kappa_pi);  % x fi       
sys_matr(2*port_out-1,2*port_in,:)   =  a*(Mach + kappa_mi);  % x gi
sys_matr(2*port_out-1,2*port_out-1,:)= -a*(Mach + kappa_pj);  % x fj
sys_matr(2*port_out-1,2*port_out,:)  = -a*(Mach + kappa_mj);  % x gj

rhs(2*port_in,:) = zeros(1, length(omega)); 
rhs(2*port_out-1,:) = zeros(1, length(omega));

  
[localMatrix, localRhs] = transformLegacyToS(sys_matr, rhs);

localMatrix = num2cell(localMatrix,3);
localRhs = num2cell(localRhs,2);
localC = {1;1};
