function [sys] = changeParam(sys,varargin)
% changeParam function to change parameters in a tax model.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% sys = getModel(sys,'Param1',Value1,'Param2',Value2,...);
% Input:        * sys: thermoacoustic network (tax) model
%               * Param1: BlockName.BlockProperty (e.g. INLET.r)
%               * Value1: value of block property 
% Output:       * sys: thermoacoustic network (tax) model
%
% ------------------------------------------------------------------
% Authors:      Stefan Jaensch (Jaensch@tfd.mw.tum.de)
% Last Change:  23 Nov 2015
% ------------------------------------------------------------------


for i = 1:2:length(varargin)
    C = strsplit(varargin{i},'.');
    eval(['sys.Blocks{getBlock(sys,C{1})}.' strjoin(C(2:end),'.') '=varargin{i+1};'])
end


%% Execute computation
sys = update(sys);

