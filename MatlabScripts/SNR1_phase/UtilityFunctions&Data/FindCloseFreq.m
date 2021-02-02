function [frequency, nominal, noise] = FindCloseFreq(Freq_list,target_freq)
%%%%%%%%%%%%%%%%%%%%%%%%%%
%   OBJECTIVE
%     =====> find the cloest FTF values as high-fidelity
%   INPUTS
%        =====> Freq_list: 1 x 2 cell, contains nominal FTF value & bootstrapping
%        =====> target_freq: n x 1, query frequency 
%   OUTPUTS
%        =====> frequency: n x 1, nominal frequency
%        =====> nominal:   n x 1, nominal FTF value
%        =====> noise:     n x 1, variance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var_value = var(Freq_list{2});   % row vector
Freq_table = 50:3:500;

frequency = zeros(size(target_freq));
nominal = zeros(size(target_freq));
noise = zeros(size(target_freq));
for i = 1:size(target_freq,1)
    [~,index] = min(abs(Freq_table-target_freq(i)));
    frequency(i) = Freq_table(index);
    nominal(i) = Freq_list{1}(index);
    noise(i) = var_value(index);
end

end

