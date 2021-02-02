function [total_time] = CalTime(frequency, cycle, overhead)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   OBJECTIVE
%        Calculate the time required to get all the frequencies
%   INPUTS
%        frequency: frequency sequence for training samples
%        cycle: number of cycles required for mono-frequency identification
%        overhead: transient time, consider as the length of impulse respones
%   OUTPUTS
%        total_time: total time spent on High-fidelity identification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

total_time = 0;
number = size(frequency,1);
for i = 1:number
    total_time = total_time + 1/frequency(i)*cycle + overhead;
end

end

