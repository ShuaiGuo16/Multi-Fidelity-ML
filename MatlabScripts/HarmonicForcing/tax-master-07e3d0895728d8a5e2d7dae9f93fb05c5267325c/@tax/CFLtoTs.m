function Ts = CFLtoTs(sys, cfl)
% calculates time step corresponding to specific CFL number
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% Ts = CFLtoTs(sys, cfl);
% Input:        * sys: tax object
%               * cfl: maximum CFL number
% Output:       * Ts: corresponding time step
% ------------------------------------------------------------------
% Authors:      Stefan Jaensch (jaensch@tfd.mw.tum.de)
% Last Change:  23 Mar 2016
% ------------------------------------------------------------------
% See also Duct.CFLtoTs

Ts = inf;
for i = 1:length(sys.Blocks)
   if isa(sys.Blocks{i},'Duct')
      Ts = min(Ts,CFLtoTs(sys.Blocks{i},cfl));
   end
end
   

