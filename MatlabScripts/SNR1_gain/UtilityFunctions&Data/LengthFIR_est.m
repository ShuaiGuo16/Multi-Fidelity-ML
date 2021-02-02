function [ FIR_vector, FIR_var ] = LengthFIR_est(time_length, dataseries)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  OBJECTIVE
%       =====> Generate FIR based on the desired length                   
%  Input:
%       =====> time_length: Desired time length
%              dataseries: Full length time series (type: iddata)
%  Output:
%       =====> FIR_vector: FIR coefficients (row vector)
%       =====> FIR_var: Variance matrix of FIR coefficients 
%                                  (column vector)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
% Package: System Identification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end_time = time_length;

% Cut data according to the time length
selected_data = dataseries(1:ceil(end_time/dataseries.Ts));

% FIR identification
nb = 30; % number of non-zero impulse response coefficients
model = impulseest(selected_data,nb);

FIR_vector = model.Numerator;
FIR_var = getcov(model);
FIR_var = FIR_var(1:nb,1:nb);

end

