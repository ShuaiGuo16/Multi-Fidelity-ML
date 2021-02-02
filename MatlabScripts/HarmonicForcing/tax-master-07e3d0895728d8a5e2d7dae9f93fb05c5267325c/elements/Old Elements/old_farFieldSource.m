function [localMatrix localRhs localC]= farFieldSource(omega, mode, Block, Connection)
% far field source (open end with source term) for calculating inhomogeneous solutions of the network
switch char(Block.loc)
    case 'Upstream'
        % Flow is directed out of the element
        FlowDirection = -1;
    case 'Downstream'
        % Flow is directed into the element
        FlowDirection = +1;
end

Mach = sign(FlowDirection)*Connection{1}.Mach;
D = Connection{1}.D;
c = Connection{1}.c;
rho = Connection{1}.rho;
Amp = eval(Block.Amp{1,1});

if mode == 0
    kyd = 0;
else
    kyd = (2*mode/D)./(omega./c); 
end

facf = 1+ Mach*sqrt(1-((1-Mach^2).*kyd.^2));
facg = 1- Mach*sqrt(1-((1-Mach^2).*kyd.^2));  

localMatrix(1,1,:) = -facf./facg;

localRhs = ones(size(omega)) * Amp/(rho*c);

localMatrix = num2cell(localMatrix,3);
localRhs = num2cell(localRhs,2);
localC = {1};