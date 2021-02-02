function taXinit()
% Adds the folders of tax functions to the path and checks for the
% existance of the sparse state space (sss) class toolbox and Sitools
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% taXinit();
% ------------------------------------------------------------------
% Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------
% See also: sss,tax

taXPath = fileparts(mfilename('fullpath'));
toolPath = fileparts(taXPath);

pathCell = regexp(path, pathsep, 'split');
onPath = any(strcmp([taXPath,filesep,'elements'], pathCell));
% add the taX directory with required subdirectories to Matlab path
if not(onPath)   
    addpath(taXPath);
    addpath(genpath(fullfile(taXPath,'sss','src')));
    addpath(genpath(fullfile(toolPath,'TFDtools')));
    addpath(fullfile(taXPath,'Callbacks'));
    addpath(fullfile(taXPath,'elements'));
end

if not(exist('sss','class'))
    error('Please install sss class and add it to the matlab path.')
end