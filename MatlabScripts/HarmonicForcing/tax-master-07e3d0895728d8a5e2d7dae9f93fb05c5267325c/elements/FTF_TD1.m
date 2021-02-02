function [FTFsys,pars] = FTF_TD1(pars,~)
%% Flame Model polif11a.pdf
% TD1 Burner FTF

% Ts = 2*pi/omega; %0.0001;
Tmax = 0.1;
Ts = 1e-4;
% Frequency vector up until nyquist frequency = half the sampling frequency
omega = 2*pi*(0:(1/Tmax):(1/2*1/(Ts)));


% Gain is used for testing and tinkering
Gain=1;

a = 0.827;
tau_1 = 3.17/1000; % [ms/1000]
sigma_1 = 0.863/1000; % [ms/1000]
tau_2 = 12.4/1000; % [ms/1000]
sigma_2 = 2.70/1000; % [ms/1000]

FTF= Gain * ((1+a)*exp(-1i*omega*tau_1 - omega.^2*sigma_1^2/2) -a*exp(-1i*omega*tau_2 - omega.^2*sigma_2^2/2));

Theta = real(FRFtoUIR(FTF.').');

% Detrend
% Theta = Theta-mean(Theta);

model = idpoly([],real(Theta),[],[],[],[],Ts);

% [~, FlameName] = fileparts(Feedback.handle);
% [~, RefName] = fileparts(Reference{1}.handle);

FTFsys = ss(model);
% FTFsys.u = {RefName};
% FTFsys.y = {FlameName};
% 
% refsys = FTF_reference(Feedback, Reference);
% 
% sys = connect(FTFsys, refsys, {['f_',RefName] ,['g_',RefName]}, FlameName);

return
freq = (0:(1/Tmax):(1/2*1/(Ts)));
tau = 0:Ts:(Tmax-Ts);
%% Testing/Validation purposes
UIR = Theta/Ts;
Fnew = Theta * exp(-tau'*1i*omega);

figure('name','Impulse of FTF')
impulse(sys)

figure('name','Bode of FTF')
bode(sys,myBode(350))

figure('name','direct plot of FTF')
subplot(2,1,1)
plot(freq,abs(FTF),freq, abs(Fnew))
xlim([0 350])

subplot(2,1,2)
plot(freq,unwrap(angle(FTF)),freq, unwrap(angle(Fnew)))

figure('name','direct plot of UIR')
plot(tau, UIR)
% hold on
% plot(tau, model.b,'r.')
% xlim([0 0.25])