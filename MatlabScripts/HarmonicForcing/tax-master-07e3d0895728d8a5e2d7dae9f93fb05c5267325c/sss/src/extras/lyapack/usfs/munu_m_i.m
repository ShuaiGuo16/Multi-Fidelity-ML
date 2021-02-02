function munu_m_i(M,ML,MU,N)
%
%  Generates of the data used in 'munu_m'. Data are stored in global
%  variables.
%
%  ML, MU are generated by the routine 'munu_pre'
%
%  Calling sequence:
%
%    munu_m_i(M,ML,MU,N)
%
%  Input:
%
%    M         real matrix M
%    ML, MU    real LU factors,
%    N         real matrix N.
%
%  After calling this routine ML and MU can be deleted to save memory.
%
% 
%  LYAPACK 1.0 (Thilo Penzl, September 1999)

if nargin~=4
  error('Wrong number of input arguments.');
end

global LP_M LP_ML LP_MU LP_N

LP_ML = ML;
LP_MU = MU;
LP_M = M;
LP_N = N;






