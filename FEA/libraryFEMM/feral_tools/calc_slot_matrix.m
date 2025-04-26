function SlotMatrix  = calc_slot_matrix(NumPhases, PolePairs, Slots, Chording, NumLayers, MatrixShift, DisplayMessage)
  
% Define short variables
m = NumPhases;
pp = PolePairs;
Q = Slots; 

% Slot/pole/phase
q = Q/(2*pp)/m;

% Slot pitch mech. angle [deg] 
SlotAngle = 360/Q;

% Slot pitch el. angle [deg]
ElSlotAngle = pp*SlotAngle;

% Winding periodicity
t = gcd(Q, pp);

% Coil pitch
Yq = floor(Q/2/pp);
if Yq < 1
  Yq = 1;
end

% Chorded coil through
Yqc = Yq - Chording;

%% Check winding feasibility
if (Q/t/2 == floor(Q/t/2)) && NumLayers == 1
  warning('Winding unfeasible!')
  SlotMatrix = NaN;
  return
end

% Compute phasor angles in the range [0 ... 360) el. deg
PhasorAngles = zeros(1,Q);
alpha = 0;
for tt = 1:Q
  if (alpha >= 360)        
    alpha = alpha - 360;
  end
    PhasorAngles(Q + 1 - tt) = alpha;
    alpha = alpha + ElSlotAngle;
end
PhasorAngles = round(PhasorAngles*10000)/10000;
PhasorAngles(find(PhasorAngles == 360)) = 0;

%% Compute one layer of the slot matrix
mm = 1; % slot counter
k1 = zeros(Q, m); % 1-st layer matrix

for jj = 0 : 360/2/m : 360/2-360/2/m
    
    index_pos = find((PhasorAngles >= jj) & (PhasorAngles < (jj + 360/2/m)));
    k1(index_pos,mm) = 0.5*(-1)^(mm + 1);
    
    index_neg = find((PhasorAngles >= jj + 360/2) & (PhasorAngles < (jj + 360/2/m + 360/2)));
    k1(index_neg,mm) = 0.5*(-1)^(mm);
    
    mm = mm + 1;
    
end

%% Delete even phasors
if NumLayers == 1
  k1 = k1 * 2; % set elements to 1
  k1(2:2:Q,:) = 0; 
end

%% Compute the second layer matrix by shifting the first one
k2 = circshift(k1, Yqc);

%% Compute the complete slot matrix
K = k1 - k2;

%% Rotate slot matrix in order to have a determined alignment
SlotMatrix = circshift(K, MatrixShift);

end % function