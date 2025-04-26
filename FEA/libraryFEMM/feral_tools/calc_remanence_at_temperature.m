function Remanence = calc_remanence_at_temperature(RemanenceRef, TemperatureCoeff, TemperatureRef, Temperature)
%CALC_REMANENCE_AT_TEMPERATURE compute the permanent magnet remanence at a given temperature

Remanence = RemanenceRef - TemperatureCoeff/100*RemanenceRef * (Temperature - TemperatureRef); % [T]

end % function