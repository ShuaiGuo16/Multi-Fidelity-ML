classdef Block
    % Block class is a template for blocks of a tax network model.
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % See also: AcBlock
    
    properties
        Connection;
        uptodate;
    end
    
    properties (Abstract, Constant)
        % Port definition for an acoustic plain wave port
        Port
    end
    
    methods
        function sys = Block(varargin)
            %% The constructor assumes that it is called with port definitions.
            % Example: Block(Block.AcPort, Block.AcPort) for a two port
            % Block with 2 acoustic ports. Use empty brackets for
            % unspecified ports
            for iPort = 1:nargin
                PortProps = varargin{iPort};
                sys.Connection{iPort} = [];
                for Propc = PortProps
                    Prop = char(Propc);
                    sys.Connection{iPort}.(Prop)= [];
                end
            end
            sys.uptodate = false;
        end
        
        function sys = set.Connection(sys,con)
            if not(isequal(sys.Connection,con))
                sys.Connection = con;
                sys.uptodate = false; %#ok<MCSUP>
            end
        end
        
    end
    
    methods(Static)
        %% Determine equality with given tolerance
        function is = isequalAbs(varargin)
            x = varargin{1};
            y = varargin{2};
            if isnumeric(x)
                tol = 10^-10;
                if nargin==3
                    tol = varargin{3};
                end
                is = ( abs(x-y) <= tol );
            elseif ischar(x)
                is = strcmp(x,y);
            end
        end
        
        %% Default mean solve algorithm (check for identity)
        function con = solveMean(con)
            fields1=[];fields2=[];
            if not(isempty(con{1}))
                fields1 = fieldnames(con{1})';
            end
            if not(isempty(con{2}))
                fields2 = fieldnames(con{2})';
            end
            fields = unique([fields1,fields2]);
            
            %% Swap sign of downstream velocity
            % Downstream Block of connection has a velocity pointing
            % inwards (negative)
            if Block.checkField(con{2},'Mach')
                con{2}.Mach = -con{2}.Mach;
            end
            
            %% Propagate quantities
            for fieldc = fields
                field = char(fieldc);
                %% Check for consistency or match quantities
                if Block.checkField(con{1},field)&&Block.checkField(con{2},field)
                    if (not(Block.isequalAbs(con{1}.(field),con{2}.(field)))) && (not(strcmp(field,'idx')||strcmp(field,'dir')))
                        error('Mean values are inconsistent.')
                    end
                elseif Block.checkField(con{1},field)
                    con{2}.(field) = con{1}.(field);
                elseif Block.checkField(con{2},field)
                    con{1}.(field) = con{2}.(field);
                end
            end
            
            %% (Re)swap sign of downstream velocity
            if Block.checkField(con{2},'Mach')
                con{2}.Mach = -con{2}.Mach;
            end
        end
        
        %% Check for fully specified Port
        function check = checkPort(con,PortType)
            Ncon = length(con);
            check = ones(Ncon,1);
            
            for i = 1:Ncon
                for Meanc = PortType
                    Mean= char(Meanc);
                    if not(Block.checkField(con{i},Mean))
                        check(i)= false;
                    end
                end
            end
            check = not(any(not(check)));
            if isempty(con)
                check = false;
            end
        end
        
        %% Check for type of port
        function check = isPort(con,PortType)
            Ncon = length(con);
            check = ones(Ncon,1);
            
            for i = 1:Ncon
                for Meanc = PortType
                    Mean= char(Meanc);
                    if not(isfield(con{i},Mean))
                        check(i)= false;
                    end
                end
            end
            check = not(any(not(check)));
        end
        
        function check = checkField(con,field)
            check = true;
            if (isfield(con,field))
                if isempty(con.(field))
                    check= false;
                end
            else
                check = false;
            end
        end
        
        %% Read in Mean values from simulink models
        function con = readPort(varargin)
            params = varargin{1};
            con = varargin{2};
            for i = 1:length(con)
                for Meanc = fieldnames(con{i})'
                    Mean = char(Meanc);
                    if Block.checkField(params,Mean)
                        if (length(params.(Mean))>=i)
                            if iscell(params.(Mean)(i))
                                con{i}.(Mean) = eval(cell2mat( params.(Mean)(i) ));
                            else
                                con{i}.(Mean) = params.(Mean)(i);
                            end
                        end
                    end
                end
            end
        end
    end
    
    methods(Abstract)
        sys = update(sys)
    end
end