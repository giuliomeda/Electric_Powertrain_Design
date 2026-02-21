
%% Modulation parameters 
inverter.param.freqPWM = 8e3;                           %(Hz)
inverter.param.timePWM = 1/inverter.param.freqPWM;      %(s)
%% Voltage 
% la tensione del bus dell'inverter viene aggiornata da 24 a 400 [V]
inverter.param.voltBus = 400;                            %(V)