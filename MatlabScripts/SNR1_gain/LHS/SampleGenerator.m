clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE
%   ====> Generate Latin-Hypercube samples
%   ====> Investigate the sensitivity of harmonic 
%         excitation settings (Sec. 3.3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

HF_sample_max = 4;
LHS_max = 100;
LHS_sample = cell(HF_sample_max,1);

for i = 1:HF_sample_max
    HF_num = i+4;
    LHS_sample{i} = [0.85*lhsdesign(HF_num,LHS_max)+0.1; ones(1,LHS_max)];
end
% save './data/LHS_sample.mat' LHS_sample

% Post-processing
pick = 4;
hold on
for j = 1:100
    plot(LHS_sample{pick}(:,j),j*ones(pick+5,1),'ro','MarkerFaceColor','r','MarkerSize',8)
    plot(0,j*ones(pick+5,1),'bo','MarkerFaceColor','b','MarkerSize',8)
end
hold off
axis off

    
    