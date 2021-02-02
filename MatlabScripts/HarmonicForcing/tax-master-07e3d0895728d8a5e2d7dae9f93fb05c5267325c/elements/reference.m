classdef reference < AcBlock & sss
    % REFERENCE contains the heat release model for global heat release
    % fluctuations
    % ------------------------------------------------------------------
    % This file is part of tax, a code designed to investigate
    % thermoacoustic network systems. It is developed by the
    % Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen
    % For updates and further information please visit www.tfd.mw.tum.de
    % ------------------------------------------------------------------
    % sys = reference(pars);
    % Input:   * pars.Name:  string of name of the chokedExit
    %          * pars.Ts: desired sampling time of the model
    %          * pars.filename:  name of the file containing the model
    %          * pars.modelname: name of the model to load
    %          * pars.active:    flame is active or inactive
    % Output:  * sys: reference object
    % ------------------------------------------------------------------
    % Authors:      Thomas Emmert (emmert@tfd.mw.tum.de)
    % Last Change:  27 Mar 2015
    % ------------------------------------------------------------------
    % See also: AcBlock.Port, AcBlock, Block
    
    properties
        filename,modelname,active,pars,fMax
    end
    methods
        function sys = reference(pars)
            % Call empty constructors with correct in and output dimension
            % and port number
            sys@AcBlock(AcBlock.Port,AcBlock.Port,[]);
            sys@sss(zeros(3,2));
            
            %% Create Block from Simulink getmodel()
            sys.Name = pars.Name;
            sys.Ts = pars.Ts;
            sys.fMax = pars.fMax;
            
            sys.filename = char(pars.filename);
            sys.modelname = char(pars.modelname);
            sys.active = strcmp(pars.active, 'on');
            
            sys.pars = rmfield(pars,{'filename','modelname','Name','element','active'});
            
            con = sys.Connection;
            con{3}.FlameName = ['Q_',sys.Name];
            sys = set_Connection(sys, con);
            
        end
        %% Set functions
        function sys = set.active(sys, active)
            if not(isequal(sys.active, active))
                sys.active = active;
                sys.uptodate = false;
            end
        end
        function sys = set.filename(sys, filename)
            if not(isequal(sys.filename, filename))
                sys.filename = filename;
                sys.uptodate = false;
            end
        end
        function sys = set.modelname(sys, modelname)
            if not(isequal(sys.modelname, modelname))
                sys.modelname = modelname;
                sys.uptodate = false;
            end
        end
        function sys = set.fMax(sys, fMax)
            if not(isequal(sys.fMax, fMax))
                sys.fMax = fMax;
                sys.uptodate = false;
            end
        end
        function sys = set.pars(sys, pars)
            if not(isequal(sys.pars, pars))
                sys.pars = pars;
                sys.uptodate = false;
            end
        end
        
        %% Mean values on interfaces
        function sys = set_Connection(sys, con)
            conFl = con(3);
            con = con(1:2);
            con = Block.solveMean(con);
            con(3) = conFl;
            sys.Connection = con;
            if Block.checkPort(con(1:2),AcBlock.Port)
                sys = update(sys);
            end
        end
        
        %% Generate system
        function [sys] = update(sys)
            % FTF_REFERENCE velocity sensitive FTF Flame model reference system
            % generation.
            if sys.uptodate
                return
            end
            sys = clear(sys);
            
            % Name of u'/ubar reference velocity
            RefName = ['u_',sys.Name];
            
            Den =  1/(sys.Connection{1}.Mach*sys.Connection{1}.c);
            
            sys.D = [0 1;1 0;Den -Den];
            
            sys = twoport(sys);
            
            sys.y{3} = RefName;
            
            if sys.active
                %% Get names of signals
                [~,name,ext] = fileparts(sys.filename);
                if isempty(ext)
                    error('Specify extension (.m or .mat) of flame in reference Block.')
                else
                    if strcmp(ext,'.m')
                        [FTFsys,sys.pars] = feval(name,sys.pars,sys.state);
                    elseif strcmp(ext,'.mat')
                        FTFsys = load(sys.filename,sys.modelname); % model laden
                        FTFsys = FTFsys.(sys.modelname);
                    end
                end
%                 load(sys.filename); % model laden
                % Name of heat release Q'/Qbar
                FlameName = sys.Connection{3}.FlameName;
                
%                 FTFsys = eval(sys.modelname);
                FTFsys.u{1} = RefName;
                FTFsys.y = {FlameName};
                if (isa(FTFsys,'idpoly')||isa(FTFsys,'idtf'))
                    % Adapt and append noise input
                    FTFsys = sss(adaptTsAndDelays(FTFsys,sys.Ts,sys.fMax));
                    sys = connect(sys, FTFsys, [sys.u; FTFsys.u{1} ;FTFsys.u(FTFsys.InputGroup.Noise)], [sys.y(1:2);FlameName;RefName]);
                else
                    % Adapt and do not append noise input
                    FTFsys = sss(adaptTsAndDelays(FTFsys,sys.Ts,sys.fMax));
                    sys = connect(sys, FTFsys, [sys.u; FTFsys.u], [sys.y(1:2);FlameName;RefName]);
                end
                
                % Rename flame reference u' input to avoid reconnecting in
                % tax
                sys.y{4} = [sys.y{4},'_y'];
                
                sys.OutputGroup.Flame = [3,4];
            else
                sys.OutputGroup.Flame = 3;
            end
            
            sys.uptodate = true;
        end
    end
end