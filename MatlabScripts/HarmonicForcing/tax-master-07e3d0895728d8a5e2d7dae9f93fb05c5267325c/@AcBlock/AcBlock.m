classdef AcBlock < Block
    % AcBlock class is a template for acoustic blocks of a tax network
    % model. 
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % See also: Block
    
    properties (Constant)
        % Port definition for an acoustic plain wave port
        % * pars.rho:  {double} of density
        % * pars.Mach: {double} of Mach Number
        % * pars.c:    {double} of speed of sound
        % * pars.A:    {double} crossectional Area
        % * pars.idx:  {integer} global index of connection
        % * pars.dir:  {+-1} direction/orientation of the port (up- or downstream)
        Port = {'rho','Mach','c','A','idx','dir'};
    end
    
    properties
        state
    end
    
    methods
        function sys = AcBlock(varargin)
            sys@Block(varargin{:});
            sys.state.idx = 1;
            sys.state.x = eps;
            sys.state.rho = [];
            sys.state.c = [];
            sys.state.Mach = [];
            sys.state.A = [];
        end
        
        function state = get.state(sys)
            state= sys.state;
            [idxAcPort] = find(cellfun(@(x) Block.checkPort({x},AcBlock.Port),sys.Connection));
            [idxPortDown] = cellfun(@(x) x.dir>0,sys.Connection(idxAcPort));
            
            % Choose downstream port as state
            idx = idxAcPort(idxPortDown==1);
            if isempty(idx)
                % If no downstream ports exist, choose upstream port
                idx = idxAcPort(idxPortDown~=1);
            end
            
            if not(isempty(idx))
                for Valc = sys.Port
                    Val= char(Valc);
                    % Get state from connection
                    if not(isfield(state,Val))||isempty(state.(Val))
                        % First valid port is defining the state
                        state.(Val) = sys.Connection{idx(1)}.(Val);
                        
                        if strcmp(state,'Mach')
                            % Direction is corrected for Mach number
                            state.(Val) = sys.Connection{idx(1)}.dir*state.(Val);
                        end
                    end
                end
            end
        end
    end
end