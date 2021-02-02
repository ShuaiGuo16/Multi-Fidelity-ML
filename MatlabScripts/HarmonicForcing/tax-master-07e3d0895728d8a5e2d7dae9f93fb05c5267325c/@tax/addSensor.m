function sys = addSensor(sys,DuctName,Position)
% addSensor function connects sensors inside a duct section of the model.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% sys = tax(PathToModel);
% Input:        * sys: tax object
% Output:       * sys: tax object with sensors
% ------------------------------------------------------------------
% Authors:      Stefan Jaensch (jaensch@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------

index = find(cellfun(@(x) strcmp(x.Name,DuctName),sys.Blocks));
cDuct = sys.Blocks{index};


rho = cDuct.Connection{1}.rho;
c = cDuct.Connection{1}.c;
u = cDuct.Connection{2}.Mach * c;
lambdaMin = 1/cDuct.fMax*(u+c);
dXmax = lambdaMin/cDuct.minres;
n = ceil(cDuct.l/dXmax);
dX = cDuct.l/n;

if cDuct.l<max(Position)
   error(['Probe is positioned outside the duct. Duct length is ' num2str(cDuct.l) ' and maximum position of probe is ' num2str(max(Position))]);
end
if min(Position)<0
    error('Only positive probe positions are allowed');
end

index_fg = round(Position/dX);
index_fg = max(index_fg,1);
index_fg = min(index_fg,n-1);
format =['%0' ,num2str(ceil(log10(2*n-2))),'d' ];

DuctLabel = strsplit(cDuct.y{end},'g');
for i = 1:length(index_fg)  
  index = ~cellfun(@isempty, regexp(cDuct.y,[DuctLabel{1} 'f_' cDuct.Name '_' num2str(index_fg(i),format)]));
  flabel{i} = {[cDuct.y{index} '_y']};
  index = ~cellfun(@isempty, regexp(cDuct.y,[DuctLabel{1} 'g_' cDuct.Name '_' num2str(index_fg(i),format)]));
  glabel{i} = {[cDuct.y{index} '_y']}; 
  pLabel{i} = {['p_' cDuct.Name '_' num2str(Position(i))]};
end

probes = cellfun(@(pLabel, flabel, glabel) pProbe(pLabel, flabel, glabel, rho, c),pLabel, flabel, glabel,'UniformOutput',false);

% sys.Blocks = [sys.Blocks(1:end) probes];
sys = connect(sys,probes{:});


