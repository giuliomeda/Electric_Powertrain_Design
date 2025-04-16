clear all
close all
clc 
%% Motor model definition
motorData_Hurst_DMA0204024B101

%% Inverter model definition 
inverter_MCLV2
%% Current regulators
wgc_curr = 200*2*pi;         % (rad/s)
phim = 70*pi/180;       % (rad)


%%%
% d-axis parameters
gainPlant = 1/mot.param.resistance;
tausPlant = [1.5*inverter.param.timePWM...
             mot.param.indApp_D/mot.param.resistance];

[contr_D.param.kp, contr_D.param.ki] = ...
            PIdesign(wgc_curr,phim,gainPlant,tausPlant,inverter.param.timePWM);
%%%
% q-axis parameters
gainPlant = 1/mot.param.resistance;
tausPlant = [1.5*inverter.param.timePWM...
             mot.param.indApp_Q/mot.param.resistance];

[contr_Q.param.kp, contr_Q.param.ki] = ...
            PIdesign(wgc_curr,phim,gainPlant,tausPlant,inverter.param.timePWM);
%% Speed Regulator
wgc_speed     = 20*2*pi;
phim_speed    = 70*pi/180;

%%%
% get PI parameters

gainPlant   = 1/mot.param.frictionM;
tausPlant   = [1/wgc_curr ...
               mot.param.inertiaM/mot.param.frictionM];
[contr_Speed.param.kp, contr_Speed.param.ki] = ...
        PIdesign(wgc_speed,phim_speed,gainPlant,tausPlant,inverter.param.timePWM);
%%%
% set output limitation for the speed regulator
contr_Speed.param.outMax = mot.rated.torq;
contr_Speed.param.outMin = -mot.rated.torq;
%% Measurement
meas_MCLV2;
