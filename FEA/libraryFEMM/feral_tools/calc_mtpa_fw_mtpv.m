function [MTPA, FW, MTPV] = calc_mtpa_fw_mtpv(Map, CurrentAmplitudeRange)
%CALC_FW_MTPV computes the flux-weakening and maximum torque per voltage locus

%% Define short variables
SD = Map.SimData;

%% Set default fields if not defined
% interpolation method
% default is linear
if ~isfield(Map, 'InterpMethod')
  Map.InterpMethod = 'linear';
end

% Winding resistance
if ~isfield(Map, 'WindingResistance')
  Map.WindingResistance = SD.WindingResistance;
end

% End-winding inductance
if ~isfield(Map, 'EndWindingInductance')
  Map.EndWindingInductance = SD.EndWindingInductance;
end

% Additional losses coefficient (losses)*k
if ~isfield(Map, 'AddLossesCoeff')
  Map.AddLossesCoeff = SD.EndWindingInductance;
end

% Machine type reference frame 
if ~isfield(Map, 'DQReferenceFrame')
  Map.DQReferenceFrame = 'PM';
end

%% Define some short variables
FreqRef = Map.ElFrequency;
Ulim = Map.VoltageLimit; % voltage limit [V] (peak)
pp = Map.PolePairs; % pole pairs
InterpMethod = Map.InterpMethod; % interpolation method
Rw = Map.WindingResistance; % winding resistance [ohm]
Lew = Map.EndWindingInductance; % end-winding inductance [H]
RPM_max = Map.MaxMechSpeedRPM; % maximum mechanical speed [rpm]
Ilim_vec = CurrentAmplitudeRange; % current limit range [A] (peak)
AlphaCoeff = Map.ModelData.Stator.Material.Lamination.AlphaCoeff; % hysteresis coefficient

try % use FFT losses if they exist
  Map.HysteresisLosses = Map.FFT.Losses.Lamination.Stator.Hysteresis; % hysteresis core losses at FreqRef
  Map.EddyCurrentLosses = Map.FFT.Losses.Lamination.Stator.EddyCurrent; % eddy current core losses at FreqRef
catch % otherwise use the conventional losses
  Map.HysteresisLosses = Map.Losses.Lamination.Stator.Hysteresis; % hysteresis core losses at FreqRef
  Map.EddyCurrentLosses = Map.Losses.Lamination.Stator.EddyCurrent; % eddy current core losses at FreqRef
end

% Rotate the SyR maps to PM
if strcmp(Map.DQReferenceFrame, 'SyR')
  Map = convert_syr2pm(Map);
  CurrentAngleRange = Map.CurrentAngleRange + 90;
else
  CurrentAngleRange = Map.CurrentAngleRange;
end

%% Compute PM flux linkage
FluxPM = interp2(Map.Id, Map.Iq, Map.FluxD, 0, 0, InterpMethod);

%% initialize structure arrays
MTPA(length(Ilim_vec)) = struct;
FW(length(Ilim_vec)) = struct;
MTPV(length(Ilim_vec)) = struct;

%% Start working region computations

for kk = 1:length(Ilim_vec) % for each current amplitude
  
  Ilim = Ilim_vec(kk); % kk-th current limit
  alphaie_vec = CurrentAngleRange; % current angle range [deg]
  alphaie_step = alphaie_vec(2)- alphaie_vec(1); % step of the current angle [deg]
  
  % Compute the base point
  [~, BASE] = calc_mtpa(Map, Ilim, alphaie_vec, Ulim);
  
  NumPoints     = 100; % number of points for the constant torque region
  data.Id       = BASE.Id * ones(1, NumPoints);
  data.Iq       = BASE.Iq * ones(1, NumPoints);
  data.FluxD    = BASE.FluxD * ones(1, NumPoints);
  data.FluxQ    = BASE.FluxQ * ones(1, NumPoints);
  data.ElSpeed  = linspace(0, BASE.ElSpeed, NumPoints);
  
  % Some computations (Power, PF, Efficiency ...)
  calc_machine_outputs % (it extends the structure 'data')
  
  % Assign the computed outputs in 'data' to 'MTPA'
  MTPA = append_data_to_structure(data, MTPA, kk);
  
  % Start FW from the current angle in the base point
  CurrentAngle = BASE.CurrentAngle;
  
  % Flag to check MTPV
  ExistMTPV = 0;
  
  % Initilize rpm speed
  data.MechSpeedRPM = 0;
  
  ii = 1;
  
  while (CurrentAngle <= alphaie_vec(end) && data.MechSpeedRPM < RPM_max)
    
    data.Id       = Ilim * cosd(CurrentAngle);
    data.Iq       = Ilim * sind(CurrentAngle);
    data.FluxD    = interp2(Map.Id_vec, Map.Iq_vec, Map.FluxD, data.Id, data.Iq, InterpMethod) + Lew * data.Id;
    data.FluxQ    = interp2(Map.Id_vec, Map.Iq_vec, Map.FluxQ, data.Id, data.Iq, InterpMethod) + Lew * data.Iq;
    
    % Estimate the operating point along the MTPV locus
    [Id_mtpv, Iq_mtpv, Imtpv] = calc_mtpv_current(data.FluxD, data.FluxQ, FluxPM, data.Id, data.Iq);
    
    if Imtpv < Ilim % MTPV
      data.Id      = Id_mtpv;
      data.Iq      = Iq_mtpv;
      data.FluxD   = interp2(Map.Id_vec, Map.Iq_vec, Map.FluxD, data.Id, data.Iq, InterpMethod) + Lew * data.Id;
      data.FluxQ   = interp2(Map.Id_vec, Map.Iq_vec, Map.FluxQ, data.Id, data.Iq, InterpMethod) + Lew * data.Iq;
    end
      
    % Compute speeds
    [data.ElSpeed, data.MechSpeed, data.MechSpeedRPM, data.ElFrequency] = calc_speed(Ulim, data.FluxD, data.FluxQ, data.Id, data.Iq, Rw, pp);
       
    % Some computations (Power, PF, Efficiency ...)
    calc_machine_outputs % (it extends the structure 'data')
   
    if Imtpv >= Ilim % the MTPV current is outside the current limit
      
      % Append the machine outputs to the structure FW
      FW = append_data_to_structure(data, FW, kk);
      
    else % the MTPV current is lower than the current limit
      
      Ilim = Imtpv; % update current limit
      
      ExistMTPV = 1;
      
      if ii == 1 % initilize the MTPV structure arrays
        
        % Append the last element of FW to MTPV to have continuos lines in
        % the plot 
        MTPV = append_data_to_structure(FW(kk), MTPV, kk, length(FW(kk).MechSpeedRPM));
        
        % Reduce the current angle step for finer computations 
        alphaie_step = alphaie_step/10;
        
      end % if ii == 1

      % Append the machine outputs to the structure MTPV
      MTPV = append_data_to_structure(data, MTPV, kk);
      
      ii = ii + 1;
      
    end % if Imtpv >= Ilim
    
    % Increase current angle
    CurrentAngle = CurrentAngle + alphaie_step;
    
  end % loop WHILE
  
  % To avoid problems in the plot procedure
  % intiliaze MTPV with the last elements of FW
  if ExistMTPV == 0
    MTPV = append_data_to_structure(data, MTPV, kk);
  end
  
  % Reset some variables for a new cycle 
  ExistMTPV = 0; 
  clear data
  
end % for kk = 1 : CurrentLimVec

end % function