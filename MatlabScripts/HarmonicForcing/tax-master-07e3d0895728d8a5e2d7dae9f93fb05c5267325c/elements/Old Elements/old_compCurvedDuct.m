function [localMatrix localRhs] = compCurvedDuct(omega, mode, Block, Connection)
%This is the implementation of the compressible curved duct from Polifke's
%"Everything You Always Wanted to Know About f and g"

rank_omega =  length(omega);
tfm(1,1,:) =ones(1,rank_omega);       % init. of tfm as identity matrix[2x2xrank_omega]
tfm(2,2,:) =ones(1,rank_omega);
% %----------------------------------------

Machi = Connection{1,1}.Mach;
Di = Connection{1,1}.D;
ai = Connection{1,1}.a;
ci = Connection{1,1}.c;
l = eval(Block.l{1,1});
n = 100;
gamma = eval(Block.gamma{1,1});


%Calculate areas at points in the segment
dx = l/n;
xx = 0:dx:l; %discretized points
a_vector = zeros(1,n+1);
for kk=1:n+1
    %Evaluate the area function given in terms of x
    x = xx(kk);
    Ax = eval(Block.surface_poly{1,1});
    if ischar(Ax)
        Ax = Ax(2:end-1);
        a_vector(kk)= eval(Ax);
    else
        a_vector(kk)= Ax;
    end
end

%Check to see if the initial areas match, if not then scale the area
if ai ~= a_vector(1)
    scale = ai/a_vector(1);
    a_vector = scale*a_vector;
end

%Construct the diameter vector
d_vector = zeros(1,n+1);
switch Block.d_Auto{1,1}
    case 'on' %calculate diameter from area
        d_vector=sqrt(1.*a_vector./pi);
    case 'off' %calculate diameter from specified equation
        for kk = 1:n+1
            x = xx(kk);
            d_vector(kk) = eval(Block.d_polyin{1,1});
        end
end

%Solve for the Mach number and speed of sound at each midpoint
a_diff = [0 , diff(a_vector)];
dAa = a_diff./((a_vector));%+a_diff*0.5);
M_vec = ones(1,n+1)*Machi;
dM = zeros(1,n+1);
dc = zeros(1,n+1);
c = ones(1,n+1)*ci;
for kk = 1:n
    gm = (gamma-1)/2;
    M=M_vec(kk);
    
    dM(kk) = dAa(kk)*(1+gm*M^2)*M/(M^2-1);
    M_vec(kk+1:end) = M_vec(kk+1:end)+dM(kk);
    
%     dc(kk) = c(kk)*(-gm*M^2)*dM(kk)/(1+gm*M^2)/M;
%     c(kk+1:end) = c(kk+1:end) + dc(kk);
end

%Define the differential values
duTerm = 1./M_vec.*dM/dx + 1./c.*dc/dx; %1/u * du/dx

ky = 2*mode./d_vector;
[kx_pi,kx_mi,kappa_pi,kappa_mi]=kx_and_kappa(omega,mode,Machi,ci,Di);
[kx_pj,kx_mj,kappa_pj,kappa_mj]=kx_and_kappa(omega,mode,M_vec(end),c(end),d_vector(end));

%Iterate through the frequencies
for ii = 1:length(omega)
k = omega(ii)./c;

%Define initial transformation matrices
fgi1 = [1; 0];
fgi2 = [0; 1];
Ri = [1 1; kappa_pi(ii) kappa_mi(ii); ky(1)/kx_pi(ii)*kappa_pi(ii) ky(1)/kx_mi(ii)*kappa_mi(ii)];

% Convert fi and gi to Pi, Ui, and Vi
PUVi1 = Ri*fgi1;
PUVi2 = Ri*fgi2;
PUVj1 = PUVi1;
PUVj2 = PUVi2;

% Create the ODE matrix
N = zeros(3,3,n+1);
N(1,1,:) = 1i.*k.*M_vec-(1+M_vec.^2)./c.*dc./dx; %Row 1
N(1,2,:) = -1i.*k-2.*M_vec.*duTerm;
N(1,3,:) = -1i.*ky.*M_vec;

N(2,1,:) = -1i.*k +(2.*M_vec./c).*(dc./dx); %Row 2
N(2,2,:) = 1i.*k.*M_vec+(1+M_vec.^2).*duTerm;
N(2,3,:) = 1i*ky;

N(3,1,:) = (1-M_vec.^2)./M_vec.*1i.*ky; %Row 3
N(3,2,:) = 0;
N(3,3,:) = -(1-M_vec.^2)./M_vec.*1i.*k;

%Solve for PUVj
for kk = 1:n+1
    N(:,:,kk) = dx*(1/(1-M_vec(kk).^2))*N(:,:,kk);
    PUVj1 = N(:,:,kk)*PUVj1+PUVj1;
    PUVj2 = N(:,:,kk)*PUVj2+PUVj2;
end

% Convert Pj and Uj to fj and gj
Rj_inv = 1/(kappa_pj(ii)-kappa_mj(ii))*[-kappa_mj(ii) 1; kappa_pj(ii) -1];
fgj1 = Rj_inv*PUVj1(1:2);
fgj2 = Rj_inv*PUVj2(1:2);

% Place in the transfer matrix
tfm(:,1,ii) = fgj1;
tfm(:,2,ii) = fgj2;
end

localRhs = zeros(2,1,rank_omega);
% Convert the transformation matrix into the appropriate format;
localMatrix(1,1,:) = -tfm(2,1,:)./tfm(2,2,:); 
localMatrix(1,2,:) = 1./tfm(2,2,:);
localMatrix(2,1,:) = tfm(1,1,:)-tfm(1,2,:).*tfm(2,1,:)./tfm(2,2,:);
localMatrix(2,2,:) = tfm(1,2,:);