classdef tax < sss & AcBlock
    % ThermoAcoustic Network (tax) class
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit our homepage
    %     http://www.tfd.mw.tum.de
    % or have a look at the wiki:
    %     https://tax.wiki.tum.de
    % ------------------------------------------------------------------
    % sys = tax(PathToModel,fMax,'Param1',Value1,'Param2',Value2,...);
    % Input:        * PathToModel: string with the path to a tax simulink
    %                              model
    %               * fMax: maximum frequency to be resolved
    %     optional  * Param1: BlockName.BlockProperty (e.g. INLET.r)
    %               * Value1: value of block proporty
    %               * 'noConnect': returns unconnected tax object without
    %               evaluating evalSteadyState and changeParam (for
    %               parameter studies with variable meanflow)
    % Output:       * sys: thermoacoustic network (tax) model
    %
    % sys = tax(Blocks, Connections,fMax);
    %               * Blocks: Cell array of Block class elements that
    %               constitute the network system
    %               * Connections: Cell array describing the
    %               interconnections of the network model.
    %               * fMax: maximum frequency to be resolved
    % Output:       * sys: thermoacoustic network (tax) model
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % Copyright (C) 2015  Professur fuer Thermofluiddynamik
    % http://www.tfd.mw.tum.de
    %
    % This program is free software; you can redistribute it and/or
    % modify it under the terms of the GNU General Public License
    % as published by the Free Software Foundation; either version 2
    % of the License, or (at your option) any later version.
    %
    % This program is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with this program; if not, write to the Free Software
    % Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
    
    properties
        modelPath
        fMax
        property, xScale, format, freqScaling
        Blocks
    end
    
    properties (Constant)
        propertys = {'p_u','p/rho/c_u','f_g','impedance_admittance','intensity'};
        xScales = {'X [m]','Connection [Index]'};
        formats = {'absPhase','realImag','logAbsPhase'};
        freqScalings = {'lin','log'};
    end
    
    properties(Dependent)
        Connections
    end
    
    methods
        function sys = tax(varargin)
            sys@sss();
            sys@AcBlock([]);
            % Defaults
            sys.property = sys.propertys{1};
            sys.xScale = sys.xScales{1};
            sys.format = sys.formats{1};
            sys.freqScaling = sys.freqScalings{1};
            
            %% Retrieve system from Simulink model
            if ischar(varargin{1})
                [sys.modelPath, sys.Name] = fileparts(varargin{1});
                sys.fMax = varargin{2};
                
                if isempty(sys.modelPath)
                    % Just the name was given, path needs to be
                    % constructed from current working directory
                    sys.modelPath = fullfile(pwd,sys.Name);
                else
                    % Full path was specified
                    sys.modelPath = fullfile(sys.modelPath,sys.Name);
                end
                
                load_system(sys.modelPath);
                sys = getModel(sys);
                
            elseif iscell(varargin{1})
                %% Read in manually defined Blocks and Connections
                sys.fMax = varargin{3};
                sys.Blocks = varargin{1};
                sys.Connections = varargin{2};
            end
            
            if ~any(cellfun(@(x) strcmpi('noConnect',x),varargin))
                sys = evalSteadyState(sys);                
                sys = changeParam(sys,varargin{3:end});
            end
        end
        
        function sys = set.fMax(sys, fMax)
            if not(isequal(sys.fMax, fMax))
                sys.fMax = fMax;
                sys.uptodate = false;
            end
        end
        
        function sys = set.Connections(sys, Connections)
            % Assign indices from Connections to Blocks Connection.
            BlocksList = cellfun(@(x) x.Name, sys.Blocks, 'UniformOutput', false);
            for blockNameC = BlocksList
                blockName = char(blockNameC);
                idxBlk = strcmp(blockName,BlocksList);
                
                % Upstream Connections
                indexConnectionUp = find(strcmp(Connections(:,3),blockName));
                for id = indexConnectionUp'
                    sys.Blocks{idxBlk}.Connection{cell2mat(Connections(id,4))}.idx = id;
                    sys.Blocks{idxBlk}.Connection{cell2mat(Connections(id,4))}.dir = -1;
                end
                % Downstream Connections
                indexConnectionDown = find(strcmp(Connections(:,1), blockName));
                for id = indexConnectionDown'
                    sys.Blocks{idxBlk}.Connection{cell2mat(Connections(id,2))}.idx = id;
                    sys.Blocks{idxBlk}.Connection{cell2mat(Connections(id,2))}.dir = 1;
                end
            end
            sys.uptodate = false;
        end
        
        function Connections =  get.Connections(sys)
            % Retrieve Connections from Block Connection indices
            Connections = {};
            nBlocks = size(sys.Blocks,2);
            for i = 1:nBlocks
                nCons = size(sys.Blocks{i}.Connection,2);
                for ii = 1:nCons
                    if sys.Blocks{i}.Connection{ii}.dir==1
                        Connections{sys.Blocks{i}.Connection{ii}.idx,1} = sys.Blocks{i}.Name; %#ok<AGROW>
                        Connections{sys.Blocks{i}.Connection{ii}.idx,2} = ii; %#ok<AGROW>
                    elseif sys.Blocks{i}.Connection{ii}.dir==-1
                        Connections{sys.Blocks{i}.Connection{ii}.idx,3} = sys.Blocks{i}.Name; %#ok<AGROW>
                        Connections{sys.Blocks{i}.Connection{ii}.idx,4} = ii; %#ok<AGROW>
                    else
                        % no entry as the connection is an open end
                    end
                end
            end
        end
    end
    
    methods(Static)
        plotParameterStudy(J,combinations,Labels,iX,iY)
    end
    
end