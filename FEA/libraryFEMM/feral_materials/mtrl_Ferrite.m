function material = mtrl_Ferrite(Temperature)
%MTRL_Ferrite defines the properties of the 'Ferrite' material

FunctionName = mfilename;
MaterialName = FunctionName(6:end);

% set default temperature is not defined
if nargin < 1
  Temperature = 20;
end

material.Name = [MaterialName,'@',num2str(Temperature),'C'];
material.TemperatureRef = 20; % [C]
material.RelativePermeability = [1.05 1.05];
material.RemanenceRef = 0.425; % [T]
material.RemanenceTemperatureCoeff = 0.2; % [%T/C]
material.Temperature = Temperature;

% compute the permanent magnet remanence at 'Temperature'
material.Remanence = calc_remanence_at_temperature( material.RemanenceRef, ...
                                                    material.RemanenceTemperatureCoeff, ...
                                                    material.TemperatureRef, ...
                                                    material.Temperature); % [T]

material.CoerciveField = material.Remanence / (4e-7*pi * material.RelativePermeability(1)); % [A/m]

% Additional properties
material.ElConductivity= 3.22; % [MS/m]
material.MassDensity = 7500; % [kg/m3]
material.SpecificCost = 7; % [euro/kg]

end % function