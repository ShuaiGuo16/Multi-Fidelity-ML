%% Transformation Transfer to scatter using System representation
% pp/(rho*c) = f+g
% up = f-g

% Input: Transfermatrix definition
% ppd/(rho*c) = T* ppu/(rho*c)
% upd              upu

% Output: Scatteringmatrix definition
% gu = S * fu
% fd       gd

% Transformation definition 
% fu+gu           fu 
% fu-gu = Trans * gd 
% fd+gd           gu
% fd-gd           fd


%% Generic implementation and Proof:
function [S, OMEGA, InvM] = TtoS(T)
TransTransferScatter = [1 0 1 0; 1 0 -1 0; 0 1 0 1; 0 -1 0 1];
% System in Transfer representation
SysTrans = [T(1,1) T(1,2) -1 0; T(2,1) T(2,2) 0 -1; 0 0 0 0; 0 0 0 0];
% Check transformation by retransformation
% SysTrans = [TfromScatter(1,1) TfromScatter(1,2) -1 0; TfromScatter(2,1) TfromScatter(2,2) 0 -1; 0 0 0 0; 0 0 0 0]
SysTransScatter = SysTrans*TransTransferScatter;
% Disassembly and Inversion
m= [SysTransScatter(1,3) SysTransScatter(1,4); SysTransScatter(2,3) SysTransScatter(2,4)];
r= [SysTransScatter(1,1) SysTransScatter(1,2); SysTransScatter(2,1) SysTransScatter(2,2)];
InvM = (inv(-m));
SfromTrans = inv(-m)*r;
S= SfromTrans;

%% Fast implementation for usual Transformation
% function [S, OMEGA] = transformTtoS(T)
% 
OMEGA = T(1,1) -T(1,2) -T(2,1) +T(2,2);
% S(1,1) = 1- (2*(T(1,1)-T(2,1)))/(OMEGA); % -T11 -T12 +T21 +T22
% S(1,2) = 2/(OMEGA);
% S(2,1) = (2*(T(1,1)*T(2,2)-T(1,2)*T(2,1)))/(OMEGA);
% S(2,2) = (T(1,1) -T(1,2) +T(2,1) -T(2,2))/(OMEGA); % T21-T22 +T11 -T12 -T21 +T22