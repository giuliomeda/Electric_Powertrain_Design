%% Current measurement
% 12 bit ADC
%meas.curr.quant     = 4.4/2^(12-1);     % 1 bit va riservato per il segno
meas.curr.quant = 1200 / 2^(15-1);
%% Position measurement
% Encoder 250 ppr (pulse per revolution)
meas.pos.quant      = 2*pi /2^14;

%% Speed measurement
meas.speed.n_tabs = 20;