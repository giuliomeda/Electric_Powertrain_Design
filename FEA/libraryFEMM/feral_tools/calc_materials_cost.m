%% SCRIPT CALLED BY SIM_VAR_ROTOR_POSITION

%% Compute materials cost

% convetional computation for stator core and winding
% core
Res.Cost.Stator.Lamination.Teeth  = Res.Weight.Stator.Lamination.Teeth * s.Material.Lamination.SpecificCost;
Res.Cost.Stator.Lamination.Yoke   = Res.Weight.Stator.Lamination.Yoke * s.Material.Lamination.SpecificCost;
Res.Cost.Stator.Lamination.Total  = Res.Cost.Stator.Lamination.Teeth + Res.Cost.Stator.Lamination.Yoke;
% winding
Res.Cost.Stator.Conductor         = Res.Weight.Stator.Conductor * s.Material.Slot.SpecificCost;
% total stator
Res.Cost.Stator.Total             = Res.Cost.Stator.Lamination.Total + Res.Cost.Stator.Conductor;
% total model = total stator (no computations for rotor)
Res.Cost.Total                    = Res.Cost.Stator.Total;

% element by element computation
if SD.IronLossesFFT == 1 || SD.GetElmByElmProp == 1
  
  % STATOR
  % stator core
  Res.EbE.Cost.Stator.Lamination.Teeth = Res.EbE.Weight.Stator.Lamination.Teeth * s.Material.Lamination.SpecificCost;
  Res.EbE.Cost.Stator.Lamination.Yoke = Res.EbE.Weight.Stator.Lamination.Yoke * s.Material.Lamination.SpecificCost ;
  Res.EbE.Cost.Stator.Lamination.Total = Res.EbE.Cost.Stator.Lamination.Teeth + Res.EbE.Cost.Stator.Lamination.Yoke;
  % stator winding
  Res.EbE.Cost.Stator.Conductor = Res.EbE.Weight.Stator.Conductor * s.Material.Slot.SpecificCost;
  % stator total
  Res.EbE.Cost.Stator.Total = Res.EbE.Weight.Stator.Lamination.Total + Res.EbE.Weight.Stator.Conductor;
 
  % ROTOR
  % rotor core
  Res.EbE.Cost.Rotor.Lamination = Res.EbE.Weight.Rotor.Lamination * r.Material.Lamination.SpecificCost;
  % rotor PMs
  Res.EbE.Cost.Rotor.Magnet = Res.EbE.Weight.Rotor.Magnet * r.Material.Magnet.SpecificCost;
  % rotor total
  Res.EbE.Cost.Rotor.Total = Res.EbE.Cost.Rotor.Lamination + Res.EbE.Cost.Rotor.Magnet;
  
  % TOTAL COMPUTATIONS
  % lamination
  Res.EbE.Cost.Lamination = Res.EbE.Cost.Stator.Lamination.Total + Res.EbE.Cost.Rotor.Lamination;
  % conductor
  Res.EbE.Cost.Conductor = Res.EbE.Cost.Stator.Conductor;
  % magnet
  Res.EbE.Cost.Magnet = Res.EbE.Cost.Rotor.Magnet;

  % total
  Res.EbE.Cost.Total = Res.EbE.Cost.Stator.Total + Res.EbE.Cost.Rotor.Total;

end

