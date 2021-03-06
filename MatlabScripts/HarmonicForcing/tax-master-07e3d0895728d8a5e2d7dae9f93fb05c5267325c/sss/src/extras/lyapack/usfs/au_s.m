function Y = au_s(tr,X,i)
%
%  Solves shifted linear systems with the real matrix A or its 
%  transposed A':
%
%  for tr = 'N':
%
%    Y = inv(A+p(i)*I)*X;
%
%  for tr = 'T':
%
%    Y = inv(A.'+p(i)*I)*X.
%
%  The LU factors of A+p(i)*I are provided as global data. This data 
%  must be generated by calling 'au_s_i' before calling this routine!
%
%  Calling sequence:
%
%    Y = au_s(tr,X,i)
%
%  Input:
%
%    tr        (= 'N' or 'T') determines whether shifted systems with 
%              A or A' should be solved;
%    X         a matrix of proper size;
%    i         the index of the shift parameter.
%
%  Output:
%
%    Y         the resulting solution matrix.
%  
%
%   LYAPACK 1.6 (Jens Saak October 2007)

if nargin~=3
  error('Wrong number of input arguments.');
end

global LP_LC LP_UC LP_aC LP_oC LP_SC

is_init1 = length(LP_LC{i});
is_init2 = length(LP_UC{i});
is_init3 = length(LP_aC{i});
is_init4 = length(LP_oC{i});
is_init5 = length(LP_SC{i});

if ~is_init1 || ~is_init2 || ~is_init3 || ~is_init4 || ~is_init5
  error('This routine needs global data which must be generated by calling ''au_s_i'' first.');
end 

if tr=='N'
  Y(LP_oC{i},:) = LP_UC{i}\(LP_LC{i}\(LP_SC{i}(:,LP_aC{i})\X));
elseif tr=='T'
  Y = (LP_SC{i}(:,LP_aC{i})).'\(LP_LC{i}.'\(LP_UC{i}.'\(X(LP_oC{i},:))));
else
  error('tp must be either ''N'' or ''T''.');
end


