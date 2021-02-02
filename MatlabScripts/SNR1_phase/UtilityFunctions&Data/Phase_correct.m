function [phase_MC_correct] = Phase_correct(phase_MC,phase_ref)

% Extract matrix dimensions
frequency_num = size(phase_MC,1);
MC_num = size(phase_MC,2);

% Flatten the matrix to ease indexing
phase_MC_flat = phase_MC(:);
phase_ref_flat = repmat(phase_ref,1,MC_num);
phase_ref_flat = phase_ref_flat(:);

% Calculate the difference between MC samples and reference
phase_diff = phase_MC_flat-phase_ref_flat;

% Obtain the index with wrongly calculated phase
index = abs(phase_diff)>pi;
ratio = round(abs(phase_diff(index))/(2*pi));

% Correct phase adjustment
phase_adjust = zeros(size(phase_MC_flat));
phase_adjust(index) = -sign(phase_MC_flat(index)-phase_ref_flat(index)).*ratio*2*pi;
phase_MC_correct = phase_MC_flat + phase_adjust;

% Reshape the matrix
phase_MC_correct = reshape(phase_MC_correct,frequency_num,MC_num);

end

