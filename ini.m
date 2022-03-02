%% write the TITLE of your PROGRAM here 
close all
clear all
clc

%% PLL Parameters -> Rotor parameters referred to the stator side

f = 50;         % Stator frequency (Hz)
Pn = 2e6;       % Rated stator power (W)
n = 1500;       % Rated rotational speed (rev/min)
Vs = 690;       % Rated stator voltage (V)
Is = 1760;      % Rated stator current (A)
Tem = 12732;    %Rated torque (N.m)

p=2;                            % Pole pair
u = 1/3;                        % Stator/rotor turns ratio
Vr = 220;                      % Rated rotor voltage (non-reached) (V)
smax = 1/3;                     % Maximu slip
Vr_stator = (Vr*smax)*u;        % Rated rotor voltage refered to stator (V)
Rs = 2.6e-3;                    % Stator resistance (ohm)
Lls = 0.087e-3;                 % Leakage inductance (stator and rotor) (H)
Lm = 2.5e-3;                    % Magnetizing / Mutual inductance (H)
Rr = 2.9e-3;                    % Rotor resistance refered to stator (ohm)
Ls = Lm + Lls;                  % Stator inductance (H)
Lr = Lm + Lls;                  % Rotor inductance (H)
Vbus = Vr_stator*sqrt(2);       % DC de bus voltage refered to stator (V)
sigma = 1 - Lm^2/(Ls*Lr);       % 
Fs = Vs*sqrt(2/3)/(2*pi*f);     % Stator Flux (aprox.) (Wb)


%Mechanical Parameters

J = 127;                        % Inertia force
D = 1e-2;                       % Friction Pair

fsw = 4e3;
Ts = 1/fsw/50;

%PI regulators

tau_1 = (sigma*Lr)/Rr;
tau_n = 0.05;
wn1 = 100*(1/tau_1);
wnn = 1/tau_n;

kp_id = (2*wn1*sigma*Lr)-Rr;
kp_iq = kp_id;
ki_id = (wn1^2)*Lr*sigma;
ki_iq = ki_id;
kp_n = (2*wnn*J)/p;
ki_n =((wnn^2)*J)/p;

%Initial Slip Conditions [1 0 0 0 0 0 0 0]. Machine will start from 0 speed

%the blade wind turbine model

N = 100;
Radio = 42;
ro = 1.255;

%ct dan cp curves

beta = 0;
ind2=1;

for lambda=0.1:0.01:11.8;
    
   lambdai(ind2) = (1./((1./(lambda-0.02.*beta)+(0.003./(beta^3+1)))));
    Cp (ind2) = 0.73.*(151./lambdai (ind2) - 0.58.*beta - 0.002.*beta^2.14-13.2).*(exp (-18.4./lambdai (ind2)));
    Ct (ind2) = Cp (ind2)/lambda;
    ind2 = ind2 + 1;
end
tab_lambda = (0.1:0.01:11.8);

Cp_max = 0.44;
lambda_opt = 7.2;
kopt = ((0.5*ro*pi*(Radio^5)*Cp_max)/(lambda_opt^3));

%grid side converter
Cbus = 80e-3;
Rg = 20e-6;
Lg = 400e-6;

Kpg = 1/(1.5*Vs*sqrt(2/3));
Kqg = -Kpg

%PI regulation

tau_ig = Lg/Rg;
wnig = 60*2*pi;

kp_idg = (2*wnig*Lg)-Rg;
kp_iqg = kp_idg;
ki_idg = (wnig^2)*Lg;
ki_iqg =ki_idg;

kp_v = -1000;
ki_v = -300000;

Rcrowbar = 1/5;