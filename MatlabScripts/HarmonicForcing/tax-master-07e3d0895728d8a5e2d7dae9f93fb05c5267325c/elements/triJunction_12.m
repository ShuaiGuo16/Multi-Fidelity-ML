function [sys] = triJunction_12(Block, Connection)
% TRIJUNCTION12 
% 
% (c) Copyright 2010 tdTUM. All Rights Reserved.

error('Old file')

port_in=1;
port_out1=2;
port_out2=3;

output = [0 1 1 0 1 0];
input = ~output;

zetaj = eval(cell2mat(Block.zetaj));
zetak = eval(cell2mat(Block.zetak));

Machi = Connection{1}.Mach;
Di = Connection{1}.D;
ai = Connection{1}.a;
ci = Connection{1}.c;

Machj = Connection{2}.Mach;
Dj = Connection{2}.D;
aj = Connection{2}.a;
cj = Connection{2}.c;

Machk = Connection{3}.Mach;
Dk = Connection{3}.D;
ak = Connection{3}.a;
ck = Connection{3}.c;

%----------------------------------------------
omega=1;
mode=0;
[kx_pi,kx_mi,kappa_pi,kappa_mi] = kx_and_kappa(omega,mode,Machi,ci,Di);
[kx_pj,kx_mj,kappa_pj,kappa_mj] = kx_and_kappa(omega,mode,Machj,cj,Dj);
[kx_pk,kx_mk,kappa_pk,kappa_mk] = kx_and_kappa(omega,mode,Machk,ck,Dk);
%-------------------------------------------------

sys_matr(2*port_in,2*port_in-1,:)= 1+ Machi*kappa_pi;                       % x fi
sys_matr(2*port_in,2*port_in,:)=1+ Machi*kappa_mi;                          % x gi

sys_matr(2*port_out1-1,2*port_in-1,:)=1+ Machi*kappa_pi;                    % x fi
sys_matr(2*port_out1-1,2*port_in,:)=1+ Machi*kappa_mi;                      % x gi

sys_matr(2*port_out2-1,2*port_in-1,:)=ai*(Machi + kappa_pi);                % x fi
sys_matr(2*port_out2-1,2*port_in,:)= ai*(Machi + kappa_mi);                 % x gi


sys_matr(2*port_in,2*port_out1-1,:)=-1*(1+ Machj*kappa_pj*(1+zetaj));       % x fj
sys_matr(2*port_in,2*port_out1,:)=-1*(1+ Machj*kappa_mj*(1+zetaj));         % x gj

sys_matr(2*port_out1-1,2*port_out1-1,:)=0;                                  % x fj  Added, but might not be necessary
sys_matr(2*port_out1-1,2*port_out1,:)=0;                                    % x gj  since the default is zero

sys_matr(2*port_out2-1,2*port_out1-1,:)= -aj*(Machj + kappa_pj);            % x fj  corrected
sys_matr(2*port_out2-1,2*port_out1,:)=-aj*(Machj + kappa_mj);               % x gj  corrected


sys_matr(2*port_in,2*port_out2-1,:)= 0;                                     % x fk  Added, but might not be necessary
sys_matr(2*port_in,2*port_out2,:)=0;                                        % x gk  since the default is zero 

sys_matr(2*port_out1-1,2*port_out2-1,:)=-1*(1+ Machk*kappa_pk*(1+zetak));   % x fk
sys_matr(2*port_out1-1,2*port_out2,:)=-1*(1+ Machk*kappa_mk*(1+zetak));     % x gk

sys_matr(2*port_out2-1,2*port_out2-1,:)= -ak*(Machk + kappa_pk);            % x fk  corrected
sys_matr(2*port_out2-1,2*port_out2,:)=-ak*(Machk + kappa_mk);               % x gk  corrected

sys_matr(end+1,:) = 0;

%-----------------------------------------

% Coefficients for outputs
A = sys_matr(find(output),find(output),:);
B = sys_matr(find(output),find(input),:);

localMatrix = -inv(A)*B;


sys = ss(localMatrix);

sys.OutputGroup.Acoustic = 1:length(sys.y);
sys.InputGroup.Acoustic = 1:length(sys.u);