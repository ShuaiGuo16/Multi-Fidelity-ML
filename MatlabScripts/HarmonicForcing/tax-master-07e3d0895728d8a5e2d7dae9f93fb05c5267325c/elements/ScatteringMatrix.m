classdef ScatteringMatrix < AcBlock & sss
    % ScatteringMatrix block class. This can be used to load custom
    % scattering matrices into tax. It is deprecated by the Element class.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % sys = ScatteringMatrix(pars);
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
        function sys = ScatteringMatrix(varargin)
            % Call empty constructors with correct in and output dimension
            % and port number
            sys@AcBlock(AcBlock.Port,AcBlock.Port);
            sys@sss(zeros(2,2));
            
            if (nargin==1)&&(isstruct(varargin{1}))
                %% Create Block from Simulink getmodel()
                %% Load model
                filename = char(varargin{1}.filename);
                modelname = char(varargin{1}.modelname);
                load(filename);
                sys = eval(modelname);
                
                sys.Name = varargin{1}.Name;
                sys.fileName = filename;
                sys.modelName = modelname;
                
                sys.StateGroup.(sys.Name) = 1:sys.n;
                
                sys.Connection = sys.Connection;
            elseif (nargin>1)
                %% Load sparse state space and connections
                sys = sys.updatesss(varargin{1});
                sys = sys.set_Connection(varargin{2});
                if (nargin>2)
                    sys.state = varargin{3};
                end
            end
        end
        
        %% Mean values on interfaces
        function sys = set_Connection(sys, con)  
            sys.Connection = con;
            
            if Block.checkPort(con,AcBlock.Port)
                sys = update(sys);
            end
        end
        
        %% Generate system
        function [sys] = update(sys)
            if sys.uptodate
                return
            end
            sys.OutputGroup.f = 1:length(sys.y);
            sys.InputGroup.g = 1:length(sys.u);
            
            % Naming convention for Scattering matrixes
            for i = 1: size(sys.Connection,2)
                if sys.Connection{i}.Mach>0
                    sys.y{i} = [num2str(sys.Connection{i}.idx,'%02d'),'f'];
                    sys.u{i} = [num2str(sys.Connection{i}.idx,'%02d'),'g'];
                else
                    sys.y{i} = [num2str(sys.Connection{i}.idx,'%02d'),'g'];
                    sys.u{i} = [num2str(sys.Connection{i}.idx,'%02d'),'f'];
                end
            end
            
            sys.uptodate = true;
        end
    end
end