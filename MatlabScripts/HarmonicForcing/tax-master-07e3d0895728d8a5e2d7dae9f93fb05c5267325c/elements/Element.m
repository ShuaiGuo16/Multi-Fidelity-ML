classdef Element < AcBlock & sss
    % Element generic tax element block class. This can be used to
    % load custom made Blocks, AcBlocks, sss,... into tax.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % sys = Element(pars);
    % Input:   * pars.Name:      string of name of the chokedExit
    %          * pars.fileName:  filename of model
    %          * pars.modelName: name of the model
    % optional * pars.(...): see link to AcBlock.Port definitions below to
    %          specify mean values and port properties in constructor
    % Output:  * sys: Element object
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % See also: AcBlock.Port, AcBlock, Block, sss
    
    properties
        fileName,modelName
    end
    methods
        function sys = Element(varargin)
            % Call empty constructors with correct in and output dimension
            % and port number
            if (nargin==1)&&(isstruct(varargin{1}))
                %% Create Block from Simulink getmodel()
                pars = varargin{1};
                nPorts = eval(cell2mat(pars.nIn)) + eval(cell2mat(pars.nOut));
                ports = cell(nPorts,1);
                con = ports;
                filename = char(pars.filename);
                modelname = char(pars.modelname);
                name = pars.Name;
                importSys = load(filename,modelname);
                importSys = importSys.(modelname);
            elseif (nargin==2)
                %% Manually create Block
                importSys = varargin{1};
                con = varargin{2};
                ports = cellfun(@(x) fieldnames(x)', con ,'UniformOutput', false);
                name = importSys.Name;
                filename = '';
                modelname = '';
            end
            sys@AcBlock(ports{:});
            sys@sss();
            sys.Connection = con;
            
            %% Load model
            if isa(importSys,'Element')
                %% Overwrite Block if it is an Element
                sys = importSys;
            else
                %% Update system Matrices if it is something else
                sys = sys.updatesss(importSys);
            end
            
            sys.Name = name;
            sys.fileName = filename;
            sys.modelName = modelname;
            sys.StateGroup.(sys.Name) = 1:sys.n;
            sys.Connection = sys.Connection;
        end
        %% Mean values on interfaces
        function sys = set_Connection(sys, con)
            sys.Connection = con;
            sys = update(sys);
        end
        
        function sys =  update(sys)
            for i = 1:length(sys.Connection)
                if Block.isPort(sys.Connection(i),AcBlock.Port)
                    portName = ['port',num2str(i)];
                    if (sys.Connection{i}.dir==1) % upstream port
                        sys.y{sys.OutputGroup.(portName)} = [num2str(sys.Connection{i}.idx,'%02d'),'f'];
                        sys.u{sys.InputGroup.(portName)}  = [num2str(sys.Connection{i}.idx,'%02d'),'g'];
                        sys.OutputGroup.f = sys.OutputGroup.(portName);
                    else % downstream port
                        sys.u{sys.InputGroup.(portName)}  = [num2str(sys.Connection{i}.idx,'%02d'),'f'];
                        sys.y{sys.OutputGroup.(portName)} = [num2str(sys.Connection{i}.idx,'%02d'),'g'];
                        sys.OutputGroup.g = sys.OutputGroup.(portName);
                    end
                end
            end
            sys.uptodate = true;
        end
    end
end