function [A,B,C,prm,iprm] = au_pre(A,B,C)
%
%  Preprocessing of the system
%    .
%    x  =  A x + B u
%    y  =  C x,
%
%  where A is SPARSE.
%
%  The preprocessing consists of a permutation of the state 
%
%    x <-- P * x
%
%  with a permutation matrix P for bandwidth reduction, which 
%  results in "overwriting" the system matrices as
%
%    A <-- P * A * P',  B <-- P * B,  C <-- C * P'.
%
%  The bandwidth of the reordered matrix A is often much smaller than that
%  of the original matrix. 
%
%  Note that this preprocessing does not affect the input-output
%  mapping of the dynamical system.
%
%  This routine can also be applied when there is no underlying dynamical
%  system. For example, this is the case when only the Lyapunov equation
%
%    A*X + X*A' = - B*B'   ( or A'*X + X*A = - C'*C )
%   
%  needs to be solved. Here, B (or C) can be omitted; see (1) (or (2)).
%
%  Calling sequence:
%
%    [A,B,C,prm,iprm] = au_pre(A,B,C)
%    [A,dummy,C,prm,iprm] = au_pre(A,[],C)                       (1)
%    [A,B,dummy,prm,iprm] = au_pre(A,B,[])                       (2)
%
%  Input:
%
%    A         n-x-n system matrix; 
%    B         n-x-m system matrix;
%    C         q-x-n system matrix.
%
%  Output:
%
%    A, B, C   permuted system matrices;
%    prm       the permutation that has been used;
%    iprm      the inverse permutation (needed to re-reorder certain data
%              in postprocessing);
%    dummy     a dummy output argument (dummy = [] is returned).
%
%
%  LYAPACK 1.0 (Thilo Penzl, May 1999)

% Input data not completely checked!

if any(any(imag(A))) || any(any(imag(B))) || any(any(imag(C)))
  disp('WARNING in ''au_pre'': A, B, and C must be real matrices.');
  pause(10)
end 

[prm,iprm] = lp_prm(A,'rcm');

A = A(prm,prm);

if ~isempty(B)
  B = B(prm,:);
end

if ~isempty(C)
  C = C(:,prm);
end
