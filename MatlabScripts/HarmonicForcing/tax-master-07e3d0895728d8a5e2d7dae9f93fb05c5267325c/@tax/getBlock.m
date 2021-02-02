function index = getBlock(varargin)
% scatter function removes parts of the system, that are not part of the
% scattering matrix specified by the user.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% sys = getBlock(sys, identifier, Block);
% Input:        * sys: tax object
%               * identifier: 'Name' or 'class'
%               * name: name of block or class type of block as string
%               or cell array for selection of multiple blocks. Supports
%               regular expressions
% Output:       * index: index of block
% ------------------------------------------------------------------
% Authors:      Stefan Jaensch (jaensch@tfd.mw.tum.de)
% Last Change:  25 Jun 2015
% ------------------------------------------------------------------
% See also regexp

sys= varargin{1};
identifier = 'Name';
name = varargin{2};

if nargin==3
    identifier = varargin{2};
    name = varargin{3};
end
if strcmp(identifier,'Name')
    blockNames = cellfun(@(x) x.Name, sys.Blocks,'UniformOutput',false);
elseif strcmp(identifier,'class')
    blockNames = cellfun(@(x) class(x), sys.Blocks,'UniformOutput',false);
end

if ~iscell(name)
    name = {name};
end

index = zeros(size(blockNames));
for i = 1:length(name)
    index = index | cellfun(@(x) ~isempty(regexp(x,['^',name{i},'$'])),blockNames);
end
