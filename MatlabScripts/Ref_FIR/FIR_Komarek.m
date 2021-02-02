clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTIVE
%   ====> Construct FIR according to Komarek's model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by S. Guo (TUM), Sept. 2019
% Email: guo@tfd.mw.tum.de
% Version: MATLAB R2018b
% Ref: [1] T. Komarek, W. Polifke, "Impact of Swirl Fluctuations on the
%          Flame Response of a Perfectly Premixed Swirl Burner", 
%          ASME J. Eng. Gas Turbines Power, 132(6), p.061503
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Basic input
N = 30; delta_t = 4.5875e-4; 
flame_base = [3.5,8.5,9.4,0.6,0.5,0.8]/1000;

% Plot the nominal FIR 
figure(1)
FIR_ref = FIR_coeff_filling(flame_base,N,delta_t);
FIR_ref = [0,FIR_ref];

time = 0:delta_t:N*delta_t;
stem(time,FIR_ref,'k','filled','LineWidth',1,'MarkerSize',8)
axis([0 0.012 -0.3 0.3])
xticks(0:0.003:0.012)
h = gca;
h.FontSize = 14;
xlabel('Time (s)','FontSize',14)
ylabel('Amplitude','FontSize',14)

% Plot the nominal FTF
max_Freq = 500;
freq = 0:1:max_Freq; 
complex_matrix = zeros(N,size(freq,2));
for index_i = 1:N
    for index_j = 1:size(freq,2)
        complex_matrix(index_i,index_j) = exp(-1i*index_i*delta_t*freq(index_j)*2*pi);
    end
end
FTF = FIR_ref(2:end)*complex_matrix;
mag = abs(FTF);
phase = unwrap(angle(FTF),[],2);

figure(2)
plot(freq,mag,'k','LineWidth',1.2)
axis([0 max_Freq -0 2])
xticks(0:100:max_Freq)
yticks(0:0.5:2)
h = gca;
h.FontSize = 17;
xlabel('Frequency (Hz)','FontSize',17)
ylabel('Gain','FontSize',17)

figure(3)
plot(freq',phase,'k','LineWidth',1.2)
axis([0 max_Freq -7*pi 0])
xticks(0:100:max_Freq)
yticks([ -6*pi -4*pi -2*pi 0])
yticklabels({'-6\pi' '-4\pi' '-2\pi' '0'})
h = gca;
h.FontSize = 17;
xlabel('Frequency (Hz)','FontSize',17)
ylabel('Phase','FontSize',17)
