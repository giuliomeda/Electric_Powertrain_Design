warning off backtrace

% Set missing mass density
s.Material.Lamination = warning_missing_field(s.Material.Lamination, 'MassDensity', 0, {s.Material.Lamination.Name});
s.Material.Slot = warning_missing_field(s.Material.Slot, 'MassDensity', 0, {s.Material.Slot.Name});
r.Material.Lamination = warning_missing_field(r.Material.Lamination, 'MassDensity', 0, {r.Material.Lamination.Name});
r.Material.Magnet = warning_missing_field(r.Material.Magnet, 'MassDensity', 0, {r.Material.Magnet.Name});

% Set missing specific cost
s.Material.Lamination = warning_missing_field(s.Material.Lamination, 'SpecificCost', 0, {s.Material.Lamination.Name});
s.Material.Slot = warning_missing_field(s.Material.Slot, 'SpecificCost', 0, {s.Material.Slot.Name});
r.Material.Lamination = warning_missing_field(r.Material.Lamination, 'SpecificCost', 0, {r.Material.Lamination.Name});
r.Material.Magnet = warning_missing_field(r.Material.Magnet, 'SpecificCost', 0, {r.Material.Magnet.Name});

% set iron losses properties
s.Material.Lamination = warning_missing_field(s.Material.Lamination, 'HysteresisCoeff', 0, {s.Material.Lamination.Name});
s.Material.Lamination = warning_missing_field(s.Material.Lamination, 'AlphaCoeff', 0, {s.Material.Lamination.Name});
s.Material.Lamination = warning_missing_field(s.Material.Lamination, 'BetaCoeff', 0, {s.Material.Lamination.Name});
s.Material.Lamination = warning_missing_field(s.Material.Lamination, 'EddyCurrentCoeff', 0, {s.Material.Lamination.Name});

% Set rotor iron losses coefficients
r.Material.Lamination = warning_missing_field(r.Material.Lamination, 'HysteresisCoeff', 0, {r.Material.Magnet.Name});
r.Material.Lamination = warning_missing_field(r.Material.Lamination, 'AlphaCoeff', 0, {r.Material.Magnet.Name});
r.Material.Lamination = warning_missing_field(r.Material.Lamination, 'BetaCoeff', 0, {r.Material.Magnet.Name});
r.Material.Lamination = warning_missing_field(r.Material.Lamination, 'EddyCurrentCoeff', 0, {r.Material.Magnet.Name});

if SD.MagnetLossesFFT 
  % Set magnet electric conductivity
  s.Material.Magnet = warning_missing_field(s.Material.Lamination, 'ElConductivity', 0, {r.Material.Magnet.Name});
end

warning on backtrace
