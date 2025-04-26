%% SCRIPT CALLED BY SIM_VAR_ROTOR_POSITION

%% Compute materials weight

% convetional computation for stator core and winding
% core
Res.Weight.Stator.Lamination.Teeth  = Res.Volume.Stator.Lamination.Teeth * s.Material.Lamination.MassDensity;
Res.Weight.Stator.Lamination.Yoke   = Res.Volume.Stator.Lamination.Yoke * s.Material.Lamination.MassDensity;
Res.Weight.Stator.Lamination.Total  = Res.Weight.Stator.Lamination.Teeth + Res.Weight.Stator.Lamination.Yoke;
% winding
Res.Weight.Stator.Conductor         = Res.Volume.Stator.Conductor * s.Material.Slot.MassDensity;
% total stator
Res.Weight.Stator.Total             = Res.Weight.Stator.Lamination.Total + Res.Weight.Stator.Conductor;
% total model = total stator (no computations for rotor)
Res.Weight.Total                    = Res.Weight.Stator.Total;


% element by element computation
if SD.IronLossesFFT == 1 || SD.GetElmByElmProp == 1 
  
  % STATOR
  % stator core
  Res.EbE.Weight.Stator.Lamination.Teeth = Res.EbE.Volume.Stator.Lamination.Teeth * s.Material.Lamination.MassDensity;
  Res.EbE.Weight.Stator.Lamination.Yoke = Res.EbE.Volume.Stator.Lamination.Yoke * s.Material.Lamination.MassDensity;
  Res.EbE.Weight.Stator.Lamination.Total = Res.EbE.Weight.Stator.Lamination.Teeth + Res.EbE.Weight.Stator.Lamination.Yoke;
  % stator winding
  Res.EbE.Weight.Stator.Conductor = Res.EbE.Volume.Stator.Conductor * s.Material.Slot.MassDensity;
  % stator total
  Res.EbE.Weight.Stator.Total = Res.EbE.Weight.Stator.Lamination.Total + Res.EbE.Weight.Stator.Conductor;
 
  % ROTOR
  % rotor core
  Res.EbE.Weight.Rotor.Lamination = Res.EbE.Volume.Rotor.Lamination * r.Material.Lamination.MassDensity;
  % rotor PMs
  Res.EbE.Weight.Rotor.Magnet = Res.EbE.Volume.Rotor.Magnet * r.Material.Magnet.MassDensity;
  % rotor total
  Res.EbE.Weight.Rotor.Total = Res.EbE.Weight.Rotor.Lamination + Res.EbE.Weight.Rotor.Magnet;
  
  % TOTAL COMPUTATIONS
  % lamination
  Res.EbE.Weight.Lamination = Res.EbE.Weight.Stator.Lamination.Total + Res.EbE.Weight.Rotor.Lamination;
  % conductor
  Res.EbE.Weight.Conductor = Res.EbE.Weight.Stator.Conductor;
  % magnet
  Res.EbE.Weight.Magnet = Res.EbE.Weight.Rotor.Magnet;
  % total
  Res.EbE.Weight.Total = Res.EbE.Weight.Stator.Total + Res.EbE.Weight.Rotor.Total;
  
end
