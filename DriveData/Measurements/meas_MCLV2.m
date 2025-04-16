%% Current measurement
% 12 bit ADC
meas.curr.quant     = 4.4/2^(12-1);     % 1 bit va riservato per il segno

%% Position measurement
% Encoder 250 ppr (pulse per revolution)
meas.pos.quant      = 2*pi /250;

%% Speed measurement
meas.speed.n_tabs = 10;