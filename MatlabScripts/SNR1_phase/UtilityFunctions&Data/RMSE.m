function [ rmse,e ] = RMSE(x,y)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Objective (for phase):
%       =====> Calculate root-mean-square-error 
%                    between two vectors
%  Input:
%       =====> x: n x 1 vector
%              y: n x 1 vector (treat as reference)
%  Output:
%       =====> e: RMSE error between x & y
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = size(x,1);
e = zeros(n,1);
for i = 1:n
    A = [abs(x(i)-y(i)),abs(x(i)-2*pi-y(i)),abs(x(i)+2*pi-y(i))];
    distance = min(A);
    e(i) = distance^2;
end

rmse = sqrt(mean(e));

end

