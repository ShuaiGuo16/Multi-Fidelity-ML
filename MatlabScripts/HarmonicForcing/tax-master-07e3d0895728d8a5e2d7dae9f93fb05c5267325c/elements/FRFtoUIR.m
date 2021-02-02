function UIR = FRFtoUIR(FRF)

warning('Legacy model! DO NOT USE THIS.')

% Rebuild complex conjugate part
FRF_conj = [ FRF; conj(FRF(end-1:-1:2))];

N = length(FRF_conj);
% Invert frequency transformation
UIR = 1 * ifft(FRF_conj); % Would need to be divided by 2 depending on definition of FRF
% N/2
%% fft works as well if correctly applied/ normalized
% Reconstruct original length of signal
% L = (length(FRF)-1)*2;
% UIR = 1/(L)*fft(FRF_conj);
% Reverse time 
% UIR =  UIR(end:-1:1); % invert signal
% UIR = [UIR(end); UIR(1:end-1)]; % rearrange first element