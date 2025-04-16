function [kp,ki] = PIdesign(wgc,phim,gainPlant,tausPlant,timeC)
%PIDESIGN Summary of this function goes here
%   'wgc' : desired bandwidth in rad/s
%   'phim' : phase margin in rad
%   'gainPlant' : static gain of the plant transfer function 
%   'tausPlant' : poles of the plant transfer function
%   'timeC' : Discrete control time

%% Transfer function
s = tf('s');

% Plant transfer function
sysPlant = gainPlant * (1/(s*tausPlant(1) + 1)) * ...
                       (1/(s*tausPlant(2) + 1));

%%%
%Get the delta_K and delta_phi

[magP,phaP] = bode(sysPlant,wgc);
deltaK = 1/magP;
deltaPhi = -pi + phim - phaP*pi/180;

%%%
% Get kp and ki of the PI regulator

kp = deltaK * cos(deltaPhi);
ki = -wgc * deltaK * sin(deltaPhi);

if (nargin == 5)
    %%% discrete time case
    ki = ki * timeC;

elseif(nargin == 4)
    %%% continuous time case

else 
    error('Number of input argument is not correct');
end


