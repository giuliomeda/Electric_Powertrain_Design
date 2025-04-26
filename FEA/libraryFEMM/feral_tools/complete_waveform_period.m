function v = complete_waveform_period(v)
%COMPLETE_WAVEFORM_PERIOD extends the 60-el.deg data to a period 

FluxA = [v.FluxA, -v.FluxB, v.FluxC];
FluxB = [v.FluxB, -v.FluxC, v.FluxA];
FluxC = [v.FluxC, -v.FluxA, v.FluxB];

v.FluxA = [FluxA, -FluxA];
v.FluxB = [FluxB, -FluxB];
v.FluxC = [FluxC, -FluxC];

v.FluxD = repmat(v.FluxD, 1, 6);
v.FluxQ = repmat(v.FluxQ, 1, 6);
v.TorqueMXW = repmat(v.TorqueMXW, 1, 6);
v.TorqueDQ = repmat(v.TorqueDQ, 1, 6);

RotorPositionsStep = v.RotorPositions(2) - v.RotorPositions(1);
v.RotorPositions = v.RotorPositions(1) + RotorPositionsStep*[0:6*length(v.RotorPositions)-1];

end % function