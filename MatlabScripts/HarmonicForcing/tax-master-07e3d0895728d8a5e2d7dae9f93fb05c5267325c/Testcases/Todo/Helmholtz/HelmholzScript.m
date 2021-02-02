% Command line interface for taX.
% It can execute taX from commandline
close all
clear
clc

taXfile = which('taX');
taXPath = fileparts(taXfile);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% User settings

domain = {'frequency','time'};
handles.domain = 'frequency';

% the frequency vector "omega"
if strcmp(handles.domain,'frequency')
    % Frequency array (set by user)
    f = 1: 1: 100; % linearly sampled
    %f = exp(log(1): log(1.1): log(500)); % logarithmically sampled
    %f = [1, 500]; % manual selection
    handles.omega = 2 * pi * f;
    freqScaling = {'linear','log'}; % for plotting
    handles.freqScaling = 'linear';
else
    % Time length and resolution
    tStep = 0.001;
    handles.omega = 2*pi* (1/tStep);
end

% Simulink model
modelName = 'Helmholtz_LS';
% modelName = 'Helmholtz_PF';

modelFolder = ['testcases' filesep 'Helmholtz'];
handles.modelPath = [taXPath filesep modelFolder filesep modelName];
% open_system(handles.modelPath);

% Choose your procedure
% allowed are: 'eigenValues', 'frequencyResponse', 'nyquist',
% 'transferMatrix' and 'miMoNyquist'.
handles.procedure = 'frequencyResponse';
% Result should be:
% Frequency:            382.6 [Hz]	Growth rate: 0.000

% Choose your desired property
% allowed are: 'p','u','f','g','r','impedance','intensity' and 'rayleigh'.
handles.property = 'u';

% Choose the X-Axis scale
xScale = {'index','position'};
handles.xScale = xScale{2};

% Choose your format
% allowed are: 'realImag', 'absPhase' and 'logAbsPhase'.
handles.format = 'logAbsPhase';

handles.showStateVectorPlot = true;

% Set the desired mode number
% 0 for pure axial modes
handles.mode = 0;

% show the model, if desired
open_system(handles.modelPath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize simulation

% create modelName for plot titles
[~, handles.modelName, ~] = fileparts(handles.modelPath); % get file name

% Adds the taXgui directory with required subdirectories to Matlab search path
% taXgui directory
addpath(taXPath);

%  add subdirectories to the path
subpaths = genpath([taXPath filesep 'mfunction']);
addpath(subpaths);

% Create Blocks and Connections structures from simulink model
[handles.Blocks handles.Connections handles.Flames] = ...
    getModel(handles.modelPath, handles.modelName);

% Manual override of Parameters
% handles.Blocks.simpleDuct1.c = {'300'}
% handles.Blocks.simpleDuct1.rho = {'1'}
% handles.Blocks.simpleDuct1.Mach = {'0'}
% handles.Blocks.simpleDuct1.D = {'1'}
% handles.Blocks.simpleDuct1.a = {'1'}

[handles.Blocks handles.Connections handles.Flames] = ...
    evalSteadyState(handles.Blocks, handles.Connections, handles.Flames);

%% Execute computation
if strcmp(handles.domain,'frequency')
    result = taX(handles);
else
    result = taXTD(handles);
end

%% Postprocessing
% calculate a frequency vector
result.omega = handles.omega;
result.frequency = handles.omega/(2*pi);

%% Visualization


