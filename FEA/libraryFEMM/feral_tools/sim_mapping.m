function [Map, Skew] = sim_mapping(MD, SD)
%% SIM_MAPPING simulate the model in the Id-Iq plane

%% Save initial time
Res.StartTime = datestr(clock, 31);

%% Set default settings if not defined
default_data_settings
[MD, SD] = set_default_data_settings(MD, SD, DefaultSettings);

%% Set default plot settings if not defined
[MD, SD] = set_default_plot_settings(MD, SD);

%% Change options for sim_var_rotor_position
% Display progress or not 
% (default is 1)
% it shows the progress state in the command window
DisplayProgress = SD.DisplayProgress;
SD.DisplayProgress = 0; 

% Disable result saving
SaveResults = SD.SaveResults; 
SD.SaveResults = 0; 

% Disable plot results 
PlotResults = SD.PlotResults; 
SD.PlotResults = 0; 

% Disable warning messages 
Warning = SD.Warning; 
SD.Warning = 'off';  

%% Start loops
% Total number of simulations
NumOfSimulations = length(SD.Id_vec) * length(SD.Iq_vec);
SimCounter = 1;
TotalSimulationTime = 0;

dd = 1; % d-axis current counter
qq = length(SD.Iq_vec); % q-axis current counter

for Id = SD.Id_vec
 
  for Iq = SD.Iq_vec
    
    SD.CurrentAmplitude = hypot(Id,Iq);
    SD.CurrentAngle = atan2d(Iq,Id);

    [res, ~, skew] = sim_var_rotor_position(MD, SD);
    SimulationTime = res.TotalSimulationTime;
    TotalSimulationTime = TotalSimulationTime + SimulationTime;

    if DisplayProgress == 1
      more off % for Octave compatibility
      disp(['Process state ', num2str(SimCounter/NumOfSimulations*100,2),' %'])
      disp(['Simulation ', num2str(SimCounter),' of ',num2str(NumOfSimulations)])
      disp(['Remaining time ', num2str((NumOfSimulations - SimCounter)*SimulationTime),' seconds, ', num2str((NumOfSimulations - SimCounter)*SimulationTime/60),' minutes, ',num2str((NumOfSimulations - SimCounter)*SimulationTime/60/60),' hours']);
    end
    
    % save 'sim_var_rotor_position' results
    % Skewed map
    Map.Id(qq,dd) = Id;
    Map.Iq(qq,dd) = Iq;
    Map.CurrentAmplitude(qq,dd) = res.CurrentAmplitude;
    Map.CurrentAngle(qq,dd) = res.CurrentAngle;
    Map.FluxD(qq,dd) = res.FluxD;
    Map.FluxQ(qq,dd) = res.FluxQ;
    Map.Flux(qq,dd) = hypot(res.FluxD, res.FluxQ);
    Map.TorqueMXW(qq,dd) = res.TorqueMXW;
    Map.TorqueDQ(qq,dd) = res.TorqueDQ;
    Map.ForceX(qq,dd) = res.ForceX;
    Map.ForceY(qq,dd) = res.ForceY;
    Map.Energy(qq,dd) = res.Energy;
    Map.Coenergy(qq,dd) = res.Coenergy;
    Map.IntegralAJ(qq,dd) = res.IntegralAJ;
    Map.MaxFluxDensityTeeth(qq,dd) = res.MaxFluxDensityTeeth;
    Map.MaxFluxDensityYoke(qq,dd) = res.MaxFluxDensityYoke;
    
    % save conventional losses
    Map.Losses.Lamination.Stator.Hysteresis(qq,dd) = res.Losses.Lamination.Stator.Hysteresis;
    Map.Losses.Lamination.Stator.EddyCurrent(qq,dd) = res.Losses.Lamination.Stator.EddyCurrent;
   
    % save FFT losses
    if SD.IronLossesFFT 
      Map.FFT.Losses.Lamination.Stator.Hysteresis(qq,dd) = res.FFT.Losses.Lamination.Stator.Hysteresis.Total;
      Map.FFT.Losses.Lamination.Stator.EddyCurrent(qq,dd) = res.FFT.Losses.Lamination.Stator.EddyCurrent.Total;
      Map.FFT.Losses.Lamination.Rotor.Hysteresis(qq,dd) = res.FFT.Losses.Lamination.Rotor.Hysteresis.Total;      
      Map.FFT.Losses.Lamination.Rotor.EddyCurrent(qq,dd) = res.FFT.Losses.Lamination.Rotor.EddyCurrent.Total; 
      Map.FFT.Losses.Magnet(qq,dd) = res.FFT.Losses.Magnet.Total;
    end
    
    % Save a layer for each skewing angle
    Skew.FluxD(qq,dd,:) = mean(skew.FluxD, 2);
    Skew.FluxQ(qq,dd,:) = mean(skew.FluxQ, 2);
    Skew.Flux(qq,dd,:) = hypot(Skew.FluxD(qq,dd,:), Skew.FluxQ(qq,dd,:));
    Skew.TorqueMXW(qq,dd,:) = mean(skew.TorqueMXW, 2);
    Skew.TorqueDQ(qq,dd,:) = mean(skew.TorqueDQ, 2);
    Skew.ForceX(qq,dd,:) = mean(skew.ForceX, 2);
    Skew.ForceY(qq,dd,:) = mean(skew.ForceY, 2);
    Skew.Energy(qq,dd,:) = mean(skew.Energy, 2);
    Skew.Coenergy(qq,dd,:) = mean(skew.Coenergy, 2);
    Skew.IntegralAJ(qq,dd,:) = mean(skew.IntegralAJ, 2);
    Skew.MaxFluxDensityTeeth(qq,dd,:) = mean(skew.MaxFluxDensityTeeth, 2);
    Skew.MaxFluxDensityYoke(qq,dd,:) = mean(skew.MaxFluxDensityYoke, 2);    

    SimCounter = SimCounter + 1;
    
    qq = qq - 1;
    
  end % for qq = Iq_vec
  
  qq = length(SD.Iq_vec);
  dd = dd + 1;
  
end % for dd = Id_vec

Map.Id_vec = Map.Id(1,:);
Map.Iq_vec = Map.Iq(:,1);
Map.ModelData = MD;
Map.SimData = SD;
Map.TotalSimulationTime = TotalSimulationTime;
Map.SlotCrossSection = res.SlotCrossSection;
Map.PolePairs = MD.PolePairs;
Map.ElFrequency = res.ElFrequency;
Map.WindingResistance = res.WindingResistance;
Map.EndWindingInductance = SD.EndWindingInductance;
SD.SaveResults = SaveResults; % restore SD.SaveResults;
SD.PlotResults = PlotResults; % restore SD.PlotResults
SD.Warning = Warning; % restore SD.Warning

%% Save results to file
if SD.SaveResults == 1
  
  % Set skew string
  if isfield(SD, 'SkewingAngles') && (length(SD.SkewingAngles) == 1 && SD.SkewingAngles(1) ~= 0)
    Map.SkewString = ['_skew_', number2string(SD.SkewingAngles, SD.DecimalSymbol, SD.FormatNumber),'_deg'];
  elseif isfield(SD, 'SkewingAngles') && length(SD.SkewingAngles) > 1
    Map.SkewString = ['_skew_', number2string(SD.SkewingAngles, SD.DecimalSymbol, SD.FormatNumber),'_deg'];
  else
    Map.SkewString = '';
  end
  
  Map.CurrentDString = ['Id_', number2string(SD.Id_vec, SD.DecimalSymbol, SD.FormatNumber),'_A'];
  Map.CurrentQString = ['Iq_', number2string(SD.Iq_vec, SD.DecimalSymbol, SD.FormatNumber),'_A'];
  Map.CurrentString = [Map.CurrentDString, '_', Map.CurrentQString];
  Map.RotorPositionString = ['_thme_', number2string(SD.RotorPositions*MD.PolePairs, SD.DecimalSymbol, SD.FormatNumber),'_deg'];

  
  Map.DateString = datestr(clock,30);
    
  SD.FileResultsName = ['map', Map.SkewString, '_', Map.CurrentString, Map.RotorPositionString, '_', Map.DateString, '.mat'];
   
  CompleteFileNameResults = [SD.ResultsFolder, '\', SD.FileResultsName];
  SD.CompleteFileNameResults = CompleteFileNameResults;
  
  % Clear the output structures if not required
  if nargout <= 1
    Skew = [];
  end
  
  % Save the results
  if isOctave
    % Matlab-Octave compatibility option
    % large file size are not well suported
    save(CompleteFileNameResults, 'Map', '-mat7-binary')
    save(CompleteFileNameResults, 'Skew','-append','-mat7-binary')
  else
    save(CompleteFileNameResults, 'Map', 'Skew');
  end % if isOctave
  
end % if SimInput.SaveResults == 1

%% Plot simulation results
if SD.PlotResults
  
  plot_sim_mapping_results(Map);
  
end % if SD.PlotResults

end % function