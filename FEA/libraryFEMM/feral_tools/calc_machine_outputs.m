%% Script to compute some machine outputs in process mapping
% It requires:
% Rw, pp
% data.Id, data.Iq, data.ElSpeed, data.FluxD, data.FluxQ
% Phy_mat, Pec_mat, AlphaCoeff

data.MechSpeed                = data.ElSpeed/pp;
data.ElFrequency              = data.ElSpeed/(2*pi);
data.MechSpeedRPM             = 60 * data.MechSpeed / (2*pi);
data.Flux                     = hypot(data.FluxD, data.FluxQ);
data.Torque                   = 3/2 * pp * (data.FluxD .* data.Iq - data.FluxQ .* data.Id);
data.ReactPower               = 3/2 * data.ElSpeed .* (data.FluxD .* data.Id + data.FluxQ .* data.Iq);
data.HysteresisLosses         = interp2(Map.Id_vec, Map.Iq_vec, Map.HysteresisLosses, data.Id, data.Iq, InterpMethod) .* (data.ElFrequency/FreqRef).^AlphaCoeff;
data.EddyCurrentLosses        = interp2(Map.Id_vec, Map.Iq_vec, Map.EddyCurrentLosses, data.Id, data.Iq, InterpMethod) .* (data.ElFrequency/FreqRef).^2;

[data.Ud, data.Uq, data.Voltage] = calc_voltage(data.Id, data.Iq, data.FluxD, data.FluxQ, Rw, data.ElSpeed);

if strcmp(Map.DQReferenceFrame, 'SyR')
  Id      = data.Iq;
  data.Iq = -data.Id;
  data.Id = Id;
  Ud      = data.Uq;
  data.Uq = -data.Ud;
  data.Ud = Ud;
end  

data.CurrentAmplitude        = hypot(data.Id, data.Iq);
data.CurrentAngle            = atan2d(data.Iq, data.Id);
data.IronLosses              = data.HysteresisLosses + data.EddyCurrentLosses;
data.JouleLosses             = 3/2 * Rw * data.CurrentAmplitude.^2;
data.Losses                  = data.JouleLosses + data.IronLosses;
data.MechPower               = data.Torque .* data.MechSpeed;
data.InputPower              = data.MechPower + data.Losses;
data.AppPower                = hypot(data.InputPower, data.ReactPower);
data.Phi                     = atan(data.ReactPower./data.InputPower)*180/pi;
data.PowerFactor             = cosd(data.Phi);
data.Efficiency              = data.MechPower ./ (data.InputPower) * 100;


% add here other computations ...