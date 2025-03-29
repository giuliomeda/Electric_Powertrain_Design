clear all
close all
clc 
%% Motor model definition
motorData_Hurst_DMA0204024B101

%% Inverter model definition 
inverter_MCLV2
%% Current regulators
wgc = 200*2*pi;         % (rad/s)
phim = 70*pi/180;       % (rad)


%%%
% d-axis parameters
gainPlant = 1/mot.param.resistance;
tausPlant = [1.5*inverter.param.timePWM...
             mot.param.indApp_D/mot.param.resistance];

[contr_D.param.kp, contr_D.param.ki] = ...
            PIdesign(wgc,phim,gainPlant,tausPlant);
%%%
% q-axis parameters
gainPlant = 1/mot.param.resistance;
tausPlant = [1.5*inverter.param.timePWM...
             mot.param.indApp_Q/mot.param.resistance];

[contr_Q.param.kp, contr_Q.param.ki] = ...
            PIdesign(wgc,phim,gainPlant,tausPlant);