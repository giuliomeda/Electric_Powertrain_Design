%% SCRIPT CALLED BY SIM_VAR_ROTOR_POSITION

%% Compute materials volumes from areas
StatorTeethVolume = StatorTeethArea * s.geo.StackLength * SD.PackFactor;
StatorYokeVolume = StatorYokeArea * s.geo.StackLength * SD.PackFactor;
RotorCoreVolume = RotorCoreArea * s.geo.StackLength * SD.PackFactor;
RotorMagnetVolume = RotorMagnetArea * r.geo.StackLength;

%% Convetional computation for stator core and winding
% stator core
Res.Volume.Stator.Lamination.Teeth  = s.geo.ToothWidth * s.geo.SlotHeight * s.geo.StackLength * SD.PackFactor * s.geo.Slots;
Res.Volume.Stator.Lamination.Yoke   = pi * (s.geo.OuterDiameter - StatorYokeHeight) * StatorYokeHeight * s.geo.StackLength * SD.PackFactor;
Res.Volume.Stator.Lamination.Total  = Res.Volume.Stator.Lamination.Teeth + Res.Volume.Stator.Lamination.Yoke;
% winding
Res.Volume.Stator.Conductor         = s.w.SlotFillFactor * SlotCrossSection * s.geo.Slots * Res.ConductorLength;
% total
Res.Volume.Stator.Total             = Res.Volume.Stator.Lamination.Total + Res.Volume.Stator.Conductor;      

% no computations for rotor core and PMs 
% not so easy to generalize (use FFT option instead)
% ...

%% Element by element computation
if SD.IronLossesFFT == 1 || SD.GetElmByElmProp == 1 
  
  % STATOR
  % stator core
  Res.EbE.Volume.Stator.Lamination.Teeth = StatorTeethVolume * SymFactor; % from calc_fft_iron_losses
  Res.EbE.Volume.Stator.Lamination.Yoke = StatorYokeVolume * SymFactor; % from calc_fft_iron_losses
  Res.EbE.Volume.Stator.Lamination.Total = Res.EbE.Volume.Stator.Lamination.Teeth + Res.EbE.Volume.Stator.Lamination.Yoke;
  % stator winding
  Res.EbE.Volume.Stator.Conductor = Res.Volume.Stator.Conductor; % it is computed on the FEMM cross section area
  % stator total
  Res.EbE.Volume.Stator.Total = Res.EbE.Volume.Stator.Lamination.Total + Res.EbE.Volume.Stator.Conductor;
  
  % ROTOR
  % rotor core
  Res.EbE.Volume.Rotor.Lamination = RotorCoreVolume * SymFactor; % from calc_fft_iron_losses
  % rotor PMs
  Res.EbE.Volume.Rotor.Magnet = RotorMagnetVolume * SymFactor; % from sim_var_rotor_position
  % rotor total
  Res.EbE.Volume.Rotor.ToTal = Res.EbE.Volume.Rotor.Lamination + Res.EbE.Volume.Rotor.Magnet;
  
  % TOTAL COMPUTATIONS
  % lamination
  Res.EbE.Volume.Lamination = Res.EbE.Volume.Stator.Lamination.Total + Res.EbE.Volume.Rotor.Lamination;
  % conductor
  Res.EbE.Volume.Conductor = Res.EbE.Volume.Stator.Conductor;
  % magnet
  Res.EbE.Volume.Magnet = Res.EbE.Volume.Rotor.Magnet;
  % total
  Res.EbE.Volume.Total = Res.EbE.Volume.Stator.Total + Res.EbE.Volume.Rotor.ToTal;
  
end
