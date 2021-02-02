function plotParameterStudy(J,combinations,Labels,iX,iY)
% plotParameterStudy function plots a stability map computed by
% tax/parameterStudy.
% ------------------------------------------------------------------
% This file is part of tax, a code designed to investigate thermoacoustic
% network systems. It is developed by:
% Professur fuer Thermofluiddynamik, Technische Universitaet Muenchen.
% For updates and further information please visit www.tfd.mw.tum.de
% ------------------------------------------------------------------
% plotStabilityMap(J,combinations,Labels,iX,iY);
% Input:        * J:            scalar parameter to be evalueated
%                               (e.g. eigenvalue) 
%               * combinations: parameter combinations
%               * Labels:       Identifiers of the permuted parameters
%               * iX:           (optional) parameter to be used as x axis
%               * iY:           (optional) parameter to be used as y axis
% ------------------------------------------------------------------
% Authors:      Stefan Jaensch (jaensch@tfd.mw.tum.de)
% Last Change:  15 Jun 2015
% ------------------------------------------------------------------
% See also tax/parameterStudy

if nargin == 5 
    index = [iX iY setdiff(1:size(combinations,2),[iX,iY])];
    combinations = combinations(:,index);
    Labels = Labels(:,index);
end


combinations = cell2mat(combinations);
[nCombs, nPars] = size(combinations);

if nPars==1
    plotSingle(cell2mat(J),combinations,Labels)
elseif nPars==2
    plotMap(cell2mat(J),combinations,Labels)
else
    comb2 = unique(combinations(:,3:end),'rows');
    for i = 1:size(comb2,1)
        index = ones(size(combinations,1),1);
        for j = 1:size(comb2,2)
            index = index & (combinations(:,j+2)==comb2(i,j));
        end
        figure
        plotMap(cell2mat(J(index)),combinations(index,[1 2]),Labels)
        titleString = [];
        for j = 1:size(comb2,2)
           titleString =  [titleString Labels{j+2} ': ' num2str(comb2(i,j)) ' '];
        end
        title(titleString)
    end
end

end

function plotSingle(J,combinations,Labels)
plot(combinations,J);
if min(J)<0 && max(J) >0
    hold on
    
    fun = @(x) interp1(combinations,J,x,'spline');
    x = [];
    for i = 1:length(combinations)
        x = [x fzero(fun,combinations(i))];
    end    
    x = x(x>combinations(1) & x < combinations(end));
    x = uniquetol(x,1e-6);
    plot(x,fun(x),'ok');
    plot(combinations([1,end]),zeros(1,2),'k');
    hold off
end
xlabel(Labels)
end

function plotMap(Values,combinations,Labels)
[X,Y] = meshgrid(sort(unique(combinations(:,1))),sort(unique(combinations(:,2))));
Z = griddata(combinations(:,1),combinations(:,2),Values,X,Y);
[Cf,hf] = contourf(X,Y,Z);
hold all;
[C0,h0] = contour(X,Y,Z,'LevelList',0);
hold off;
hf.LevelList = setdiff(hf.LevelList,0);
hf.ShowText = 'on';
h0.ShowText = 'on';
h0.LineWidth = 3;
h0.LineColor = 'k';
xlabel(Labels{1})
ylabel(Labels{2})
end
