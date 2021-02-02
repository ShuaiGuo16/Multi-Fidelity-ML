function varargout = eigs(sys, varargin)
% EIGS - Compute eigenvalues of the sparse state space system using sparse matrices.
%
% Syntax:
%       D = eigs(sys)
%       [V, D, flag] = eigs(sys)
%       eigs(sys,k)
%       eigs(sys,k,sigma)
%       eigs(sys,k,sigma,opts)
%
% Description:
%       Compute eigenvalues of the sparse state-space system using sparse
%       matrices.
% 
% Input Arguments:
%       *Required Input Arguments:*
%       -sys:   An sss-object containing the LTI system
%       *Optional Input Arguments:*
%       -k,sigma,opts:  Output and computation options,
%        see <a href="matlab:help eigs">eigs</a>
%
% Output:       
%       -V:     Right eigenvectors
%       -D:     Diagonal matrix of eigenvalues
%       -flag:  Convergence flag
%
% Examples:
%       The following code returns the 6 (default) eigenvalues with the
%       largest magnitude ('lm', default) of the benchmark
%       'SpiralInductorPeec':
%
%> load SpiralInductorPeec
%> p = size(C,1); m = size(B,2);
%> sys = sss(A,B,C,zeros(p,m),E);
%> D = eigs(sys)
%
%       You can use optional input arguments in order to define how many
%       eigenvalues should be computed (|k|) and in order to specify |sigma|.
%
%       The following code returs the 5 eigenvalues with the smallest
%       magnitude ('sm'):
%
%> D = eigs(sys,5,'sm')
%
% See Also: 
%        eigs
%
% References:
%       * *[1] Lehoucq, R.B. and D.C. Sorensen (1996)*, Deflation Techniques for an Implicitly Re-Started Arnoldi Iteration.
%       * *[2] Sorensen, D.C. (1992)*, Implicit Application of Polynomial Filters in a k-Step Arnoldi Method.
%
%------------------------------------------------------------------
% This file is part of <a href="matlab:docsearch sss">sss</a>, a Sparse State-Space and System Analysis 
% Toolbox developed at the Chair of Automatic Control in collaboration
% with the Chair of Thermofluid Dynamics, Technische Universitaet Muenchen. 
% For updates and further information please visit <a href="https://www.rt.mw.tum.de/">www.rt.mw.tum.de</a>
% For any suggestions, submission and/or bug reports, mail us at
%                   -> <a href="mailto:sssMOR@rt.mw.tum.de">sssMOR@rt.mw.tum.de</a> <-
%
% More Toolbox Info by searching <a href="matlab:docsearch sssMOR">sssMOR</a> in the Matlab Documentation
%
%------------------------------------------------------------------
% Authors:      Thomas Emmert
% Email:        <a href="mailto:sssMOR@rt.mw.tum.de">sssMOR@rt.mw.tum.de</a>
% Website:      <a href="https://www.rt.mw.tum.de/">www.rt.mw.tum.de</a>
% Work Adress:  Technische Universitaet Muenchen
% Last Change:  05 Nov 2015
% Copyright (c) 2015 Chair of Automatic Control, TU Muenchen
%------------------------------------------------------------------

if any(any(sys.E-speye(size(sys.E))))
    if nargout==1||nargout==0
        [varargout{1}] = eigs(sys.a, sys.e, varargin{:});
    else
        [varargout{1}, varargout{2}, varargout{3}]  = eigs(sys.a, sys.e, varargin{:});
    end
else
    if nargout==1||nargout==0
        [varargout{1}] = eigs(sys.a, varargin{:});
    else
        [varargout{1}, varargout{2}, varargout{3}]  = eigs(sys.a, varargin{:});
    end
end

% Store poles for future computations
if nargout>1
    sys.poles = varargout{2};
else
    sys.poles = varargout{1};
end

end