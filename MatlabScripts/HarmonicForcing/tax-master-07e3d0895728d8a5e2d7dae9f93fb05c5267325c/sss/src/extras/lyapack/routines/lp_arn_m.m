function [H,V] = lp_arn_m(usfs,Bf,Kf,k,r)
%
%  Arnoldi method w.r.t. inv(F), where F = A-Bf*Kf'.
%
%  Calling sequence:
%
%    [H,V] = lp_arn_m(usfs,Bf,Kf,k)
%    [H,V] = lp_arn_m(usfs,Bf,Kf,k,r)
%
%  Input:
%
%    usfs      structure of function_handles for the user supplied functions;
%    Bf        matrix Bf;
%              Set Bf = [] if not existing or zero!
%    Kf        matrix Kf;
%              Set Kf = [] if not existing or zero!
%    k         number of Arnoldi steps (usually k << n, where
%              n is the order of the system);
%    r         initial n-vector 
%              (optional - chosen by random, if omitted).
%
%  Output:
%
%    H         matrix H ((k+1)-x-k matrix, upper Hessenberg);
%    V         matrix V (n-x-(k+1) matrix, orthogonal columns).
%
%  User-supplied functions called by this function:
%
%    'usfs.m', 'usfs.i'    
%
%  Method:
%
%    The ("inverse") Arnoldi method produces matrices V and H such that
%
%      V(:,1) in span{r},
%      V'*V = eye(k+1),
%      inv(F)*V(:,1:k) = V*H.
%
%  Remark:
%
%    This implementation does not check for (near-)breakdown!
%   
%
%  LYAPACK 1.6 (Jens Saak, November 2007)

% Input data not completely checked!

na = nargin;

with_BK = ~isempty(Bf);

n = feval(usfs.m);                    % Get system order.
if k >= n-1, error('k must be smaller than the order of A!'); end
if na<5, r = randn(n,1); end 

V = zeros(n,k+1);
H = zeros(k+1,k);

V(:,1) = (1.0/norm(r))*r;

beta = 0;

if with_BK,      % SM = inv(F)*Bf*inv(I-Kf'*inv(F)*Bf)
                 % (This is the main part of the term needed for the low
                 % rank correction in the Sherman-Morrison formula.)
  Im = eye(size(Bf,2)); 
  TM = Bf;
  TM = feval(usfs.l,'N',TM);
  SM = TM/(Im-Kf'*TM);
end

for j = 1:k
 
  if j > 1
    H(j,j-1) = beta;
    V(:,j) = (1.0/beta)*r;
  end
  
  w = V(:,j);
  w = feval(usfs.l,'N',w);
  if with_BK, w = w + SM*(Kf'*w); end     % LR correction by SM formula
  r = w;
  
  for i = 1:j
    H(i,j) = V(:,i)'*w;
    r = r-H(i,j)*V(:,i);
  end

  beta = norm(r);
  H(j+1,j) = beta;
 
end  

V(:,k+1) = (1.0/beta)*r;







