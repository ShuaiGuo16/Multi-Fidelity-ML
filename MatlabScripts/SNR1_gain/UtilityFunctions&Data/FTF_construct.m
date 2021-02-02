function [gain, phase] = FTF_construct(FIR, delta_t, frequency)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Construct FTF based on FIR coefficients
%
% Inputs:
%       FIR:            FIR coefficients (row: FIR coefficients; Col: different FIR)
%       delta_t:        Sampling interval between FIR coefficients          
%       frequency:      n x 1 vector of frequency values
% Outputs:
%       gain:           Gain of FTF at selected frequency
%       phase:          Phase of FTF at selected frequency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

freq_num = size(frequency,1);
nb = size(FIR,2);
complex_matrix = zeros(nb,freq_num);

for index_i = 1:nb
    for index_j = 1:freq_num
        complex_matrix(index_i,index_j) = exp(-1i*(index_i-1)*delta_t*frequency(index_j)*2*pi);
    end
end

FTF = (FIR*complex_matrix)';
gain = abs(FTF);
phase = -unwrap(angle(FTF));


end

