function [Upper,Lower] = ConfidenceBounds_symmetry(response_data,quantile,nominal)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Objective:
%       =====> Calculate the upper and lower bounds for each column of the
%       response_data, according to the quantile value
%  Input:
%       =====> response_data: matrix (row: frequency; col: realizations)
%       =====> quantile: quantile value
%       =====> nominal: vector, the mean response value
%  Output:
%       =====> Upper: Upper bound value
%       =====> Lower: Lower bound value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

freq_num = size(response_data,1);
realization_num = size(response_data,2);
Upper = zeros(freq_num,1);
Lower = zeros(freq_num,1);
ratio = 0;

for i = 1:freq_num
    response_at_freq = response_data(i,:);
    step_size = (max(response_at_freq)-min(response_at_freq))/1000;
    k = 1;
    while ratio<quantile
        k = k + 1;
        ratio = sum(response_at_freq<(nominal(i)+k*step_size) & response_at_freq>(nominal(i)-k*step_size))...
            /realization_num;
    end     
    Lower(i) = nominal(i)-k*step_size;
    Upper(i) = nominal(i)+k*step_size;
    ratio = 0;
end

end

