% Documentation: Duct LEE upwind scheme
% Finite Difference scheme
% https://en.wikipedia.org/wiki/Finite_difference_coefficient

% Taylor expansion of stencils fi,i-1,i-2,... as a function of fi:
% a1*fi = a1*fi
% a2*fi-1 = a2*fi + a2*(-dX)*(dfi)/(dx) + a2*(-dX)^2/2*(d^2 fi)/(dx^2) + ...
% a3*fi-2 = a3*fi + a3*(-2*dX)*(dfi)/(dx) + a3*(-2*dX)^2/2*(d^2 fi)/(dx^2) +
% ...
% ...
% Summing up all equations gives:
% a1*fi + a2*fi-1 + a3*fi-2 = (a1+a2+a3)*fi+ (-a2*dX-a3*(2*dX))*(dfi)/(dX) ...
% ... +(a2*dX^2/2+a3*(2*dX)^2/2)*(d^2 fi)/(dX^2)
% Thus in order to solve the system of equations for (dfi)/(dX) the
% coefficients should sum up to one and for fi and (d^2 fi)/(dX^2) shall
% sum up to zero.
% In Matrix notation:
% A*[a1; a2; a3] = [0; 1; 0];
% [a1; a2; a3] = A⁻1*[0; 1; 0];

syms dX

%% Second Order manually
A = [1, 1, 1; 0, -dX, -2*dX; 0, dX^2/2, (2*dX)^2/2];
a = A\[0;1;0];

%% Second order generated
n= [0,-1,-2];
Duct.getCoeff(dX, n)