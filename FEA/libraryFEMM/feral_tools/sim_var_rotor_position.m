function [Res, Vec, Skew] = sim_var_rotor_position(MD, SD)
%% SIM_VAR_ROTOR_POSITION simulate the rotation of the rotor with

%% Save initial time
Res.StartTime = datestr(clock, 31);

%% Set default settings if not defined
default_data_settings
[MD, SD] = set_default_data_settings(MD, SD, DefaultSettings);

%% Set default plot settings if not defined
if SD.PlotResults == 1
  [MD, SD] = set_default_plot_settings(MD, SD);
end

% enable warning messages
warning(SD.Warning)

% print all the results in the command window
if isOctave
  more off % for Octave compatibility
end

% add underscore after FileResultsPrefix
if ~strcmp(SD.FileResultsPrefix, '') && ~strcmp(SD.FileResultsPrefix, '_')
  SD.FileResultsPrefix = [SD.FileResultsPrefix, '_'];
end

%% Define short variables
s = MD.Stator;
s.geo = s.Geometry;
s.w = s.Winding;
r = MD.Rotor;
r.geo = MD.Rotor.Geometry;
pp = MD.PolePairs;
ncs = s.w.ConductorsInSlot/s.w.ParallelPaths;
K = s.w.SlotMatrix;
Ipeak = SD.CurrentAmplitude;
alphaie = SD.CurrentAngle;
freq = MD.PolePairs * SD.MechSpeedRPM /60;
SymFactor = 2*pp/MD.SimPoles;
SimulatedSlots = s.geo.Slots / SymFactor;

if strcmp(MD.Stator.Type, 'External')
  GapPropNum = 10;
  ParSign = -1;
  StatorGapDiameter = s.geo.InnerDiameter; 
  StatorNoGapDiameter = s.geo.OuterDiameter;  
  RotorGapDiameter = r.geo.OuterDiameter;
  RotorNoGapDiameter = r.geo.InnerDiameter;
else
  GapPropNum = 11;
  ParSign = -1;
  StatorGapDiameter = s.geo.OuterDiameter;
  StatorNoGapDiameter = s.geo.InnerDiameter;  
  RotorGapDiameter = r.geo.InnerDiameter;
  RotorNoGapDiameter = r.geo.OuterDiameter;
end

if length(SD.RotorPositions) > 1
  RotorPositions_step = SD.RotorPositions(2) - SD.RotorPositions(1);
else
  RotorPositions_step = 0;
end

%% Create folders

% Temp files
if ~isfield(SD,'TempID')
  SD.TempFolder = [SD.TempFolderPath, '/', SD.TempFolderName];
else
  SD.TempFolder = [SD.TempFolderPath, '/', SD.TempFolderName, '_', num2str(SD.TempID)];
end

if ~exist(SD.TempFolder,'dir')
  mkdir(SD.TempFolder);
else % if the temporary folder already exists
  if SD.UsePreviousSolution % delete existing .ans file to prevent convergence errors
    if exist([SD.TempFolder,'/', SD.TempFileName, '.ans'], 'file')
      delete([SD.TempFolder,'/', SD.TempFileName, '.ans'])
    end
  end
end

% Results folder
if ~exist(SD.ResultsFolder, 'dir')
  mkdir(SD.ResultsFolder);
end


%% Create file results string
% Set skew string
if (length(SD.SkewingAngles) == 1 && SD.SkewingAngles(1) ~= 0)
  Res.SkewString = ['skew_', number2string(SD.SkewingAngles, SD.DecimalSymbol, SD.FormatNumber),'_deg_'];
elseif length(SD.SkewingAngles) > 1
  Res.SkewString = ['skew_', number2string(SD.SkewingAngles, SD.DecimalSymbol, SD.FormatNumber),'_deg_'];
else
  Res.SkewString = '';
end

CurrentAmplitudeString = ['Ipk_', number2string(Ipeak, SD.DecimalSymbol, SD.FormatNumber),'_A'];
CurrentAngleString = ['aie_', number2string(alphaie, SD.DecimalSymbol, SD.FormatNumber),'_deg'];
Res.CurrentString = [CurrentAmplitudeString,'_',CurrentAngleString];
Res.RotorPositionString = ['thme_', number2string(SD.RotorPositions*pp, SD.DecimalSymbol, SD.FormatNumber),'_deg'];
Res.SpeedString = ['RPM_', number2string(SD.MechSpeedRPM, SD.DecimalSymbol, SD.FormatNumber),'_rpm'];
PartialFileResultsName = ['VRP_',Res.SkewString, Res.CurrentString, '_', Res.RotorPositionString, '_', Res.SpeedString];

%% Set some material properties if missing
set_missing_material_properties

%% Open FEMM instance
if SD.SaveDensityPlots && SD.MinimizeFemm ~= 0
  warning off backtrace
  warning('MinimizeFemm set to 0 to allow image saving!')
  warning on backtrace
  SD.MinimizeFemm = 0;
end

if SD.NewFemmInstance == 1
  openfemm(SD.MinimizeFemm); % open a FEMM instance
end

%% Add sliding bands to model
filePath = fullfile(SD.ModelPath,strcat(SD.ModelName,'.fem'));
filePath = quote(filePath);
filePath = strrep(filePath,'""','"');
callfemm([ 'open(' , filePath , ')' ]);
% Set the sliding band propnum (see manual)
draw_gap_lines(MD, MD.AirgapMeshSize); % add the air-gap bands
mi_saveas([SD.TempFolder, '/', SD.ModelName, '_SB.fem']); % save the modified model
mi_close() % close the model

%% Start simulation loops
% Initialize skew index
sk = 1;
SimCounter = 1;
TotalSimulationTime = 0;
NumOfSimulations = length(SD.SkewingAngles) * length(SD.RotorPositions);

for skew = SD.SkewingAngles % for each skew angle
  
  thm = 1; % initialize rotor position index
  
  for thetam = SD.RotorPositions % for each rotor position
    
    opendocument([SD.TempFolder, '/', SD.ModelName, '_SB.fem']); % open fem model
    
    tic
    sim_pre_processing % solve the problem
    sim_post_processing % get the results
    SimulationTime = toc;
    
    mi_close(); % close pre-processing in femm
    
    TotalSimulationTime = TotalSimulationTime + SimulationTime;
    
    % Show progress state information
    if SD.DisplayProgress == 1 % basic
      disp(['Process state ', num2str(SimCounter/NumOfSimulations*100,2),' %'])
      disp(['Simulation ', num2str(SimCounter),' of ',num2str(NumOfSimulations)])
      disp(['Remaining time ', num2str((NumOfSimulations - SimCounter)*SimulationTime),' seconds, ', num2str((NumOfSimulations - SimCounter)*SimulationTime/60),' minutes, ',num2str((NumOfSimulations - SimCounter)*SimulationTime/60/60),' hours']);
    end
    
    % If there is only one skew angle
    % create two equal rows for a more general code
    if length(SD.SkewingAngles) == 1
      sk = [1 2];
      sk_Bg = 1;
    else
      sk_Bg = sk;
    end
    
    %% Store the simulation results
    Skew.RotorPositions(thm) = thetam;
    Skew.Ia(thm) = ia;
    Skew.Ib(thm) = ib;
    Skew.Ic(thm) = ic;
    Skew.CurrentInSlot(thm,:) = CurrentInSlot;
    Skew.FluxA(sk,thm) = FluxABC(1);
    Skew.FluxB(sk,thm) = FluxABC(2);
    Skew.FluxC(sk,thm) = FluxABC(3);
    Skew.FluxD(sk,thm) = FluxD;
    Skew.FluxQ(sk,thm) = FluxQ;
    Skew.TorqueMXW(sk,thm) = TorqueMXW;
    Skew.TorqueDQ(sk,thm) = TorqueDQ;
    Skew.ForceX(sk,thm) = ForceX;
    Skew.ForceY(sk,thm) = ForceY;
    Skew.Energy(sk,thm) = Energy;
    Skew.Coenergy(sk,thm) = Coenergy;
    Skew.IntegralAJ(sk,thm) = AJint;
    Skew.MaxFluxDensityTeeth(sk,thm) = MaxFluxDensityTeeth;
    Skew.MaxFluxDensityYoke(sk,thm) = MaxFluxDensityYoke;
    Skew.AirgapFluxDensity(thm,:,sk_Bg) = AirgapFluxDensity;
    Skew.AirgapFluxDensityFund(sk, thm) = AirgapFluxDensityFund;
    
    %% Store the mesh element properties
    if SD.IronLossesFFT == 1
      
      if length(SD.SkewingAngles) == 1 % only one skewing angle
        Skew.ElmAz_mat(thm,:) = ElmAz;
        Skew.ElmBx_mat(thm,:) = ElmBx;
        Skew.ElmBy_mat(thm,:) = ElmBy;
      else % more skewing angles
        Skew.ElmAz_mat(thm,:,sk) = ElmAz;
        Skew.ElmBx_mat(thm,:,sk) = ElmBx;
        Skew.ElmBy_mat(thm,:,sk) = ElmBy;
      end
      
    end % if SD.IronLossesFFT == 1
    
    % rotor position counter
    thm = thm + 1;
    
    % simulation counter
    SimCounter = SimCounter + 1;
    
  end % for thm = SD.RotorPositions
  
  % skewing counter
  sk = sk + 1;
   
  % do not remove file .ans if it is the last simulation (for user check)
  if ~(skew == SD.SkewingAngles(end))
    
    if SD.UsePreviousSolution % delete existing .ans file to prevent convergence errors
      if exist([SD.TempFolder,'/', SD.TempFileName, '.ans'], 'file')
        delete([SD.TempFolder,'/', SD.TempFileName, '.ans'])
      end
    end
    
  end
  
end % for skew = SD.Skew

%% Close FEMM instance
if SD.CloseFemm
  closefemm;
end

%% Save time
% Save current time
Res.FinishTime = datestr(clock, 31);
% Save total simulation time
Res.TotalSimulationTime = TotalSimulationTime;

%% Compute the skewed arrays
Vec.RotorPositions         = Skew.RotorPositions;
Vec.Ia                     = Skew.Ia;
Vec.Ib                     = Skew.Ib;
Vec.Ic                     = Skew.Ic;
Vec.FluxA                  = mean(Skew.FluxA);
Vec.FluxB                  = mean(Skew.FluxB);
Vec.FluxC                  = mean(Skew.FluxC);
if length(RotorPositions_step) > 1
  Vec.EmfA                   = gradient(Vec.FluxA, RotorPositions_step*pi/180);
  Vec.EmfB                   = gradient(Vec.FluxB, RotorPositions_step*pi/180);
  Vec.EmfC                   = gradient(Vec.FluxC, RotorPositions_step*pi/180);
end
Vec.FluxD                  = mean(Skew.FluxD);
Vec.FluxQ                  = mean(Skew.FluxQ);
Vec.TorqueMXW              = mean(Skew.TorqueMXW);
Vec.TorqueDQ               = mean(Skew.TorqueDQ);
Vec.RippleSTD              = std(Vec.TorqueMXW)/mean(Vec.TorqueMXW)*100;
Vec.Ripple                 = (max(Vec.TorqueMXW) - min(Vec.TorqueMXW))/mean(TorqueMXW)*100;
Vec.ForceX                 = max(Skew.ForceX);
Vec.ForceY                 = max(Skew.ForceY);
Vec.Energy                 = mean(Skew.Energy);
Vec.Coenergy               = mean(Skew.Coenergy);
Vec.IntegralAJ             = mean(Skew.IntegralAJ);
Vec.MaxFluxDensityTeeth    = mean(Skew.MaxFluxDensityTeeth);
Vec.MaxFluxDensityYoke     = mean(Skew.MaxFluxDensityYoke);
Vec.AirgapFluxDensity      = Skew.AirgapFluxDensity;
Vec.AirgapFluxDensityFund  = abs(mean(Skew.AirgapFluxDensityFund));
Vec.AirgapFluxDensityAngle = AirgapFluxDensityAngleVec;


%% Remove the second layer if only one skew is set
if length(SD.SkewingAngles) == 1
    Skew.FluxA = Skew.FluxA(1,:);
    Skew.FluxB = Skew.FluxB(1,:);
    Skew.FluxC = Skew.FluxC(1,:);
    Skew.FluxD = Skew.FluxD(1,:);
    Skew.FluxQ = Skew.FluxQ(1,:);
    Skew.TorqueMXW = Skew.TorqueMXW(1,:);
    Skew.TorqueDQ = Skew.TorqueDQ(1,:);
    Skew.ForceX = Skew.ForceX(1,:);
    Skew.ForceY = Skew.ForceY(1,:);
    Skew.Energy = Skew.Energy(1,:);
    Skew.Coenergy = Skew.Coenergy(1,:);
    Skew.IntegralAJ = Skew.IntegralAJ(1,:);
    Skew.MaxFluxDensityTeeth = Skew.MaxFluxDensityTeeth(1,:);
    Skew.MaxFluxDensityYoke = Skew.MaxFluxDensityYoke(1,:);
    Skew.AirgapFluxDensity = Skew.AirgapFluxDensity(1,:);
    Skew.AirgapFluxDensityFund = Skew.AirgapFluxDensityFund(1,:);
end

%% Compute average or max values
Res.ia                    = ia;
Res.ib                    = ib;
Res.ic                    = ic;
Res.Id                    = Id;
Res.Iq                    = Iq;
Res.CurrentAmplitude      = Ipeak;
Res.CurrentAngle          = alphaie;
Res.FluxA                 = Vec.FluxA(end);
Res.FluxB                 = Vec.FluxB(end);
Res.FluxC                 = Vec.FluxC(end);
Res.FluxD                 = mean(Vec.FluxD);
Res.FluxQ                 = mean(Vec.FluxQ);
Res.Flux                  = hypot(Res.FluxD, Res.FluxQ);
Res.TorqueMXW             = mean(Vec.TorqueMXW);
Res.TorqueDQ              = mean(Vec.TorqueDQ);
Res.ForceX                = max(Vec.ForceX);
Res.ForceY                = max(Vec.ForceY);
Res.Energy                = mean(Vec.Energy);
Res.Coenergy              = mean(Vec.Coenergy);
Res.IntegralAJ            = mean(Vec.IntegralAJ);
Res.MaxFluxDensityTeeth   = max(Vec.MaxFluxDensityTeeth);
Res.MaxFluxDensityYoke    = max(Vec.MaxFluxDensityYoke);
Res.AirgapFluxDensityFund = mean(Vec.AirgapFluxDensityFund);
Res.EndWindingLength      = MD.EndWindingLength;
Res.ConductorLength       = s.geo.StackLength + MD.EndWindingLength;

%% Compute stator Joule Losses
calc_joule_losses

%% Lamination FFT computations

% maximum flux density in the stator teeth and yoke
Bmax_t            = Res.MaxFluxDensityTeeth;
Bmax_yk           = Res.MaxFluxDensityYoke;

% Define some short variables
% Iron losses equation: Pfe = Khy * f^alpha * B^beta + Kec * f^2 * B^2
% stator lamination iron losses coefficients
StatorLamProp     = s.Material.Lamination;
RotorLamProp      = r.Material.Lamination;
StatorKhy         = StatorLamProp.HysteresisCoeff;
StatorKec         = StatorLamProp.EddyCurrentCoeff;
StatorAlphaCoeff  = StatorLamProp.AlphaCoeff;
StatorBetaCoeff   = StatorLamProp.BetaCoeff;
% rotor lamination iron losses coefficients
RotorKhy          = RotorLamProp.HysteresisCoeff;
RotorKec          = RotorLamProp.EddyCurrentCoeff;
RotorAlphaCoeff   = RotorLamProp.AlphaCoeff;
RotorBetaCoeff    = RotorLamProp.BetaCoeff;

% Compute iron losses with the FFT method
if SD.IronLossesFFT == 1 
  calc_fft_iron_losses
end

%% Get model areas from mesh properties
if SD.GetElmByElmProp == 1 
   
  % stator teeth and yoke 
  [~, StatorTeethArea, StatorYokeArea] = calc_stator_area(s, Elements); 
  % rotor core and magnet 
  [RotorCoreArea, RotorMagnetArea] = calc_rotor_area(r, Elements); 
   
else 
  
  StatorTeethArea = NaN;
  StatorYokeArea = NaN;
  RotorCoreArea = NaN;
  RotorMagnetArea = NaN;
  
end

%% Magnet FFT computations

if SD.IronLossesFFT == 1 % the element properties are already known
  
  % rotor core and magnet
  [~, RotorMagnetArea] = calc_rotor_area(r, Elements);
  
  if SD.MagnetLossesFFT == 1
    calc_fft_magnet_losses
  else
    Res.FFT.Losses.Magnet.Total = 0;
  end
else 
  Res.FFT.Losses.Magnet.Total = 0;
end % if SD.IronLossesFFT == 1

%% Compute materials volume
calc_materials_volume

%% Compute materials weight
calc_materials_weight

%% Compute materials cost
calc_materials_cost

%% Compute conventional iron losses
calc_iron_losses

%% Extend flux and torque waveforms from 60 el-deg to 360 el-deg
if SD.CompletePeriod
  Vec = complete_waveform_period(Vec);
  CompletePlotString = '_complete';
else
  CompletePlotString = '';
end

%% Save mesh nodes (heavy file)
if SD.SaveMeshNodes == 1 && (SD.IronLossesFFT || SD.GetElmByElmProp)
  Res.Mesh.Nodes.Nymber = NumNodes;
  Res.Mesh.Nodes.Coordinate.X = Xmsh;
  Res.Mesh.Nodes.Coordinate.Y = Ymsh;
end

%% Compute and save additional results
Res.DateString = datestr(clock,30);
Res.ModelData           = MD; % save model data
Res.SimData             = SD; % save simulation data
Res.SlotCrossSection    = SlotCrossSection; % Slot cross section
Res.ElFrequency         = freq; % Electrical frequency [Hz]
Res.ElSpeed             = 2*pi*Res.ElFrequency; % Electrical speed [rad/s el.]
Res.MechSpeed           = Res.ElSpeed/MD.PolePairs; % Mechanical speed [rad/s]
Res.MechSpeedRPM        = SD.MechSpeedRPM; % Mechanical speed RPM [rpm]
Res.ElSpeed             = 2*pi*freq; % Electrical speed [rad/s el.]
Res.FluxAngle           = angle(Res.FluxD + 1i*Res.FluxQ)*180/pi; % Flux angle [deg]
Res.FluxD1              = Res.FluxD + SD.EndWindingInductance * Res.Id; % d-axis flux [Vs]
Res.FluxQ1              = Res.FluxQ + SD.EndWindingInductance * Res.Iq; % q-axis flux [Vs]
Res.Flux1               = hypot(Res.FluxD1, Res.FluxQ1); % total flux with end-winding [Vs]
Res.FluxAngle1          = angle(Res.FluxD1 + 1i*Res.FluxQ1)*180/pi; % Flux angle [deg]
Res.Ud                  = Res.WindingResistance * Res.Id - Res.ElSpeed * Res.FluxQ1; % d-axis voltage [V]
Res.Uq                  = Res.WindingResistance * Res.Iq + Res.ElSpeed * Res.FluxD1; % q-axis voltage [V]
Res.Voltage             = hypot(Res.Ud, Res.Uq); % Voltage [V]
Res.AngleFluxCurrent    = Res.FluxAngle1 + 90 - Res.CurrentAngle; % Flux-Current angle displacement [deg]
Res.MechPower           = 1.5 * Res.ElSpeed * Res.Flux1 * Res.CurrentAmplitude * cosd(Res.AngleFluxCurrent); % Mechanical power [W]
Res.ReactPower          = 1.5 * Res.ElSpeed * Res.Flux1 * Res.CurrentAmplitude * sind(Res.AngleFluxCurrent); % Reactive power [Var]
Res.Losses.Total        = (Res.Losses.Conductor + Res.Losses.Lamination.Total) * SD.AddLossesCoeff; % Total losses [W]
Res.InputPower          = Res.MechPower + Res.Losses.Total; % Input active power [W]
Res.Phi                 = atand(Res.ReactPower/Res.InputPower); % Angle Phi [deg]
Res.PowerFactor         = cosd(Res.Phi); % Power factor [-]
Res.Efficiency          = Res.MechPower / (Res.MechPower + Res.Losses.Total); % Efficiency [%]
% ccomputations with FFT losses
if SD.IronLossesFFT == 1
  Res.FFT.Losses.Total     = (Res.Losses.Conductor + Res.FFT.Losses.Lamination.Total + Res.FFT.Losses.Magnet.Total) * SD.AddLossesCoeff; % Total FFT losses [W]
  Res.FFT.InputPower       = Res.MechPower + Res.FFT.Losses.Total; % Input FFT active power [W]
  Res.FFT.Phi              = atand(Res.ReactPower/Res.FFT.InputPower); % Angle FFT Phi [deg]
  Res.FFT.PowerFactor      = cosd(Res.FFT.Phi); % Power factor [-]
  Res.FFT.Efficiency       = Res.MechPower / (Res.MechPower + Res.FFT.Losses.Total); % Efficiency [%]
end

%% Plot simulation results
if SD.PlotResults == 1 && length(SD.RotorPositions) > 1
  
  plot_sim_var_rotor_position_results(Res, Vec);
  
  % close all the figures
  if SD.CloseFigures == 1
    close all
  end % if SD.PlotResults == 1
  
end

%% Save results to file
if SD.SaveResults == 1

  SD.CompleteFileNameResults = [SD.ResultsFolder, '/', SD.FileResultsPrefix, PartialFileResultsName, '_', Res.DateString, '.mat'];
  
  % Clear the output structures if not required
  if nargout <= 1
    Vec = [];
    Skew = [];
  elseif nargout == 2
    Skew = [];
  end
  
  % Save the results
  if isOctave
    % Matlab-Octave compatibility option
    % large file size are not well suported
    save(SD.CompleteFileNameResults, 'Res','-mat7-binary')
    save(SD.CompleteFileNameResults, 'Vec','-append','-mat7-binary')
    save(SD.CompleteFileNameResults, 'Skew','-append','-mat7-binary')
  else
    save(SD.CompleteFileNameResults, 'Res', 'Vec', 'Skew');
  end % if isOctave
  
end % if SD.SaveResults == 1

%% Delete auxiliary files
if SD.DeleteAuxFiles == 1 && SD.IronLossesFFT == 1
  delete([SD.TempFolder,'/', 'MeshNodes.txt']);
  delete([SD.TempFolder,'/', 'ElementsValues.txt']);
  delete([SD.TempFolder,'/', 'get_elements_values.lua']);
  delete([SD.TempFolder,'/', 'get_mesh_nodes.lua']);
end

if SD.DeleteTempFolder == 1
  if isOctave
    confirm_recursive_rmdir(0); % disable asking confirmation of Octave
    rmdir(SD.TempFolder, 's');
  else
    rmdir(SD.TempFolder, 's')
  end
end

% enable warning messages
warning('on')

 
end % function