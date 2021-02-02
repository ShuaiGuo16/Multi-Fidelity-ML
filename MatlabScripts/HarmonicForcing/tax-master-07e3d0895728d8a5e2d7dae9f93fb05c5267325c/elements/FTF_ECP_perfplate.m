function [FTFsys,pars] = FTF_ECP_perfplate(pars,~)
%% Flame Model Kaess+Polif+08.pdf
% TD1 Burner FTF

% close all

% Ts = 2*pi/omega; %0.0001;
Ts = 1/1000/5; % Response until 1000 Hz
Tmax = 0.006;
% Frequency vector up until nyquist frequency = half the sampling frequency
omega = 2*pi*(0:(1/Tmax):(1/2*1/(Ts)));


% Gain is used for testing and tinkering
Gain=1;

a = 0.906;
tau_1 = 0.912/1000; % [ms/1000]=[s]
sigma_1 = 0.334/1000; % [ms/1000] = [s]
tau_2 = 0.122/1000; % [ms/1000] = [s]
sigma_2 = 0.817/1000; % [ms/1000] = [s]

FTF= Gain * ((1+a)*exp(-1i*omega*tau_1 - omega.^2*sigma_1^2/2) -a*exp(-1i*omega*tau_2 - omega.^2*sigma_2^2/2));

% idFTF = frd(FTF,omega,Ts);
% model = spa(idFTF);

% h= rationalfit(omega, FTF);

% [resp,outfreq] = freqresp(h,omega*2);

% figure
% plot(outfreq,abs(resp))

% figure
% plot(omega*2,freqresp(h,omega*2))
% bode(model,myBode(1500))
% figure
% plot(omega, FTF,'r')

% model= s2tf(h);

Theta = real(FRFtoUIR(FTF.').');

% Detrend
% Theta = Theta-mean(Theta);

model = idpoly([],real(Theta),[],[],[],[],Ts);
% 
% [~, FlameName] = fileparts(Feedback.handle);
% [~, RefName] = fileparts(Reference{1}.handle);

FTFsys = ss(model);
% FTFsys.u = {RefName};
% FTFsys.y = {FlameName};
% 
% % Denormalize FTF reference with reference mean flow speed
% Denorm = ss(1/(Reference{1}.Connection.Mach*Reference{1}.Connection.c));
% Denorm.u = {['u_',RefName]};
% Denorm.y = {RefName};
% 
% Input  = sumblk(['u_',RefName,' = ','f_',RefName ,'-','g_',RefName]);
% 
% % Assemble input signal for FTF u'/u
% sys = connect(FTFsys, Denorm, Input, {['f_',RefName] ,['g_',RefName]}, FlameName);

return

freq = (0:(1/Tmax):(1/2*1/(Ts)));
tau = 0:Ts:(Tmax-Ts);

%% Testing/Validation purposes
UIR = Theta/Ts;
Fnew = Theta * exp(-tau'*1i*omega);

figure('name','Impulse of FTF')
% impulse(sys)
% hold on
impulse(model)

figure('name','Bode of FTF')
bode(sys,myBode())
hold on
bode(model,myBode())

figure('name','direct plot of FTF')
subplot(2,1,1)
plot(freq,abs(FTF),freq, abs(Fnew))
% xlim([0 1000])

subplot(2,1,2)
plot(freq,unwrap(angle(FTF)),freq, unwrap(angle(Fnew)))

figure('name','direct plot of UIR')
plot(tau, UIR)
hold on
% plot(tau, model.b,'r.')
% xlim([0 0.25])