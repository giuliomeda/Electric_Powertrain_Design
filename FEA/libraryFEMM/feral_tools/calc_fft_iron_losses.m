%% Script to compute the iron losses by means of the FFT method

% INPUT
% the iron losses are computed for each element of 
% the stator (teeth and yoke) and rotor
% 
% the computation starts from the behavior of the flux density (Bx, By)
% versus the rotor position for each mesh element
% 
% then, the FFT of each waveform is computed
%
% the iron losses 

% the equation is: sum (Khy * fh^alpha * Bh^2 + Kec * fh^2 * Bh^2)
%
% Khy, alpha, beta are the hysteresis iron losses coefficients
% Kec is the eddy-current iron losses coefficient
% fh is the h-th harmonic of the fundamental frequency [Hz]
% Bh is the amplitude of the h-th harmonic of the flux density [T]

for sk = 1 : length(SD.SkewingAngles)
  
  
  %% Stator iron losses (teeth and yoke)
  
 
  TeethRadius = s.geo.InnerDiameter/2 + s.geo.SlotHeight * ParSign;
  ElmBarycenterRadius = hypot(ElmBarycenter(:,1), ElmBarycenter(:,2));
  if strcmp(MD.StatorType, 'External')
    % Select the teeth elements
    TeethIndex = find(ElmGroup == s.Group & ElmBarycenterRadius <= TeethRadius);
    % Select the stator yoke elements
    YokeIndex = find(ElmGroup == s.Group & ElmBarycenterRadius > TeethRadius);
  elseif strcmp(MD.StatorType, 'Internal')
    % Select the teeth elements
    TeethIndex = find(ElmGroup == s.Group & ElmBarycenterRadius => TeethRadius);
    % Select the stator yoke elements
    YokeIndex = find(ElmGroup == s.Group & ElmBarycenterRadius < TeethRadius);   
  end
  
  for ty = 1:2 % (teeth, yoke)
    
    if ty == 1
      StatorRegionIndex = TeethIndex;
    elseif ty == 2
      StatorRegionIndex = YokeIndex;
    end % if tt
    
    StatorRegionAz = Skew.ElmAz_mat(:, StatorRegionIndex, sk);
    StatorRegionBx = Skew.ElmBx_mat(:, StatorRegionIndex, sk);
    StatorRegionBy = Skew.ElmBy_mat(:, StatorRegionIndex, sk);
    StatorRegionVolume = ElmArea(StatorRegionIndex)*s.geo.StackLength * SD.PackFactor; 
    StatorArea(ty) = sum(ElmArea(StatorRegionIndex));
    % usually is possible to mirror the flux density waveform
    %     Bx              -Bx
    % [0 --> T/2] ... [T/2 --> T]
    if SD.MirrorHalfPeriod == 1
      
      StatorRegionAz = [StatorRegionAz; -StatorRegionAz];
      StatorRegionBx = [StatorRegionBx; -StatorRegionBx];
      StatorRegionBy = [StatorRegionBy; -StatorRegionBy];
      
    end
    
    % save flux density values for each stator mesh element (heavy file)
    if SD.SaveMeshElementsValues == 1
      
      if ty == 1 % teeth
        
        Res.Mesh.Elements.Stator.Teeth.Number = size(StatorRegionBx,2);
        Res.Mesh.Elements.Stator.Teeth.Az(:,:,sk) = StatorRegionAz;
        Res.Mesh.Elements.Stator.Teeth.FluxDensityX(:,:,sk) = StatorRegionBx;
        Res.Mesh.Elements.Stator.Teeth.FluxDensityY(:,:,sk) = StatorRegionBy;
        Res.Mesh.Elements.Stator.Teeth.Coordinates.Nodes = ElmNodes(StatorRegionIndex,:);
        Res.Mesh.Elements.Stator.Teeth.Coordinates.Barycenter = ElmBarycenter(StatorRegionIndex,:);
        Res.Mesh.Elements.Stator.Teeth.Area = ElmArea(StatorRegionIndex,:);
        Res.Mesh.Elements.Stator.Teeth.Group = ElmGroup(StatorRegionIndex,:);
        
        
      elseif ty == 2 % yoke
        
        Res.Mesh.Elements.Stator.Yoke.Number = size(StatorRegionBx,2);
        Res.Mesh.Elements.Stator.Yoke.Az(:,:,sk) = StatorRegionAz;
        Res.Mesh.Elements.Stator.Yoke.FluxDensityX(:,:,sk) = StatorRegionBx;
        Res.Mesh.Elements.Stator.Yoke.FluxDensityY(:,:,sk) = StatorRegionBy;
        Res.Mesh.Elements.Stator.Yoke.Coordinates.Nodes = ElmNodes(StatorRegionIndex,:);
        Res.Mesh.Elements.Stator.Yoke.Coordinates.Barycenter = ElmBarycenter(StatorRegionIndex,:);
        Res.Mesh.Elements.Stator.Yoke.Area = ElmArea(StatorRegionIndex,:);
        Res.Mesh.Elements.Stator.Yoke.Group = ElmGroup(StatorRegionIndex,:);
        
      end % if tt
      
    end % if SD.SaveMeshElementsValues == 1
       
    % compute stator specific iron losses (hysteresis and eddy-current) for each element
    [StatorElmHarmPhy, StatorElmHarmPec] = calc_specific_iron_losses_fft(StatorRegionBx, StatorRegionBy,  freq, StatorKhy, StatorAlphaCoeff, StatorBetaCoeff, StatorKec);
    
    % compute the total stator iron losses
    if ty == 1 % teeth
      
      % stator teeth hysteresis iron losses [W]
      Res.FFT.Losses.Lamination.Stator.Teeth.Hysteresis.Vec(sk) = SymFactor*sum(StatorElmHarmPhy*StatorRegionVolume)*StatorLamProp.MassDensity * SD.LossesTeethFactor; 
      
      % stator teeth eddy-current iron losses [W]
      Res.FFT.Losses.Lamination.Stator.Teeth.EddyCurrent.Vec(sk) = SymFactor*sum(StatorElmHarmPec*StatorRegionVolume)*StatorLamProp.MassDensity * SD.LossesTeethFactor;
      
      % stator teeth total iron losses [W]
      Res.FFT.Losses.Lamination.Stator.Teeth.Total.Vec(sk) = Res.FFT.Losses.Lamination.Stator.Teeth.Hysteresis.Vec(sk) + Res.FFT.Losses.Lamination.Stator.Teeth.EddyCurrent.Vec(sk);
      
    elseif ty == 2 % yoke
      
      % stator yoke hysteresis iron losses [W]
      Res.FFT.Losses.Lamination.Stator.Yoke.Hysteresis.Vec(sk) = SymFactor*sum(StatorElmHarmPhy*StatorRegionVolume)*StatorLamProp.MassDensity * SD.LossesYokeFactor;
      
      % stator yoke eddy-current iron losses [W]
      Res.FFT.Losses.Lamination.Stator.Yoke.EddyCurrent.Vec(sk) = SymFactor*sum(StatorElmHarmPec*StatorRegionVolume)*StatorLamProp.MassDensity * SD.LossesYokeFactor;
      
      % stator yoke total iron losses [W]
      Res.FFT.Losses.Lamination.Stator.Yoke.Total.Vec(sk) = Res.FFT.Losses.Lamination.Stator.Yoke.Hysteresis.Vec(sk) + Res.FFT.Losses.Lamination.Stator.Yoke.EddyCurrent.Vec(sk); 
      
    end % if tt
    
  end % for tt = 1:2
  
  StatorTeethArea = StatorArea(1);
  StatorYokeArea = StatorArea(2);
  
  % stator hysteresis iron losses [W]
  Res.FFT.Losses.Lamination.Stator.Hysteresis.Vec(sk) = Res.FFT.Losses.Lamination.Stator.Teeth.Hysteresis.Vec(sk) + Res.FFT.Losses.Lamination.Stator.Yoke.Hysteresis.Vec(sk);
  
  % stator eddy-current iron losses [W]
  Res.FFT.Losses.Lamination.Stator.EddyCurrent.Vec(sk) = Res.FFT.Losses.Lamination.Stator.Teeth.EddyCurrent.Vec(sk) + Res.FFT.Losses.Lamination.Stator.Yoke.EddyCurrent.Vec(sk);
 
  % compute the total stator losses [W]
  Res.FFT.Losses.Lamination.Stator.Total.Vec(sk) = Res.FFT.Losses.Lamination.Stator.Hysteresis.Vec(sk) + Res.FFT.Losses.Lamination.Stator.EddyCurrent.Vec(sk);
  
  
  %% Rotor iron losses
  
  % get the rotor properties (Index, Az, Bx, By, Volume)
  RotorIndex = (ElmGroup == r.IronGroup);
  RotorAz = Skew.ElmAz_mat(:,RotorIndex,sk);
  RotorBx = Skew.ElmBx_mat(:,RotorIndex,sk);
  RotorBy = Skew.ElmBx_mat(:,RotorIndex,sk);
  RotorVolume = ElmArea(RotorIndex)*r.geo.StackLength * SD.PackFactor;
  RotorCoreArea = sum(ElmArea(RotorIndex));

  % mirror the rotor elememt values to complete an electric period
  %     Bx              -Bx
  % [0 --> 180] ... [180 --> 360]
  if SD.MirrorHalfPeriod == 1
    RotorAz = [RotorAz; RotorAz];
    RotorBx = [RotorBx; RotorBx];
    RotorBy = [RotorBy; RotorBy];
  end
  
  % save flux density values for each rotor mesh element (heavy file)
  if SD.SaveMeshElementsValues == 1
    Res.Mesh.Elements.Rotor.Number = size(RotorBx,2);
    Res.Mesh.Elements.Rotor.Az(:,:,sk) = RotorAz;
    Res.Mesh.Elements.Rotor.FluxDensityX(:,:,sk) = RotorBx;
    Res.Mesh.Elements.Rotor.FluxDensityY(:,:,sk) = RotorBy;
    Res.Mesh.Elements.Rotor.Coordinates.Nodes = ElmNodes(RotorIndex,:);
    Res.Mesh.Elements.Rotor.Coordinates.Barycenter = ElmBarycenter(RotorIndex,:);
    Res.Mesh.Elements.Rotor.Area = ElmArea(RotorIndex,:);
    Res.Mesh.Elements.Rotor.Group = ElmGroup(RotorIndex,:);
  end
  
  % compute rotor specific iron losses for each element [W/kg]
  [RotorElmHarmPhy, RotorElmHarmPec, ElFreqVec] = calc_specific_iron_losses_fft(RotorBx, RotorBy,  freq, RotorKhy, RotorAlphaCoeff, RotorBetaCoeff, RotorKec);
  
  % compute the global rotor hysteresis losses [W]
  Res.FFT.Losses.Lamination.Rotor.Hysteresis.Vec(sk) = SymFactor*sum(RotorElmHarmPhy*RotorVolume)*RotorLamProp.MassDensity;
  
  % compute the global rotor eddy-current losses [W]
  Res.FFT.Losses.Lamination.Rotor.EddyCurrent.Vec(sk) = SymFactor*sum(RotorElmHarmPec*RotorVolume)*RotorLamProp.MassDensity;
  
  % compute the total rotor losses [W]
  Res.FFT.Losses.Lamination.Rotor.Total.Vec(sk) = Res.FFT.Losses.Lamination.Rotor.Hysteresis.Vec(sk) + Res.FFT.Losses.Lamination.Rotor.EddyCurrent.Vec(sk);
  
  
end % for sk = 1 : length(SD.SkewingAngles)

%% Stator average FFT iron losses

% HYSTERESIS
% Average stator teeth hysteresis losses [W]
Res.FFT.Losses.Lamination.Stator.Teeth.Hysteresis.Avg = mean(Res.FFT.Losses.Lamination.Stator.Teeth.Hysteresis.Vec);
% Average stator yoke hysteresis losses [W]
Res.FFT.Losses.Lamination.Stator.Yoke.Hysteresis.Avg = mean(Res.FFT.Losses.Lamination.Stator.Yoke.Hysteresis.Vec);
% Average stator hysteresis losses [W]
Res.FFT.Losses.Lamination.Stator.Hysteresis.Total = Res.FFT.Losses.Lamination.Stator.Teeth.Hysteresis.Avg + Res.FFT.Losses.Lamination.Stator.Yoke.Hysteresis.Avg;

% EDDY-CURRENT
% Average stator teeth eddy-current losses [W]
Res.FFT.Losses.Lamination.Stator.Teeth.EddyCurrent.Avg = mean(Res.FFT.Losses.Lamination.Stator.Teeth.EddyCurrent.Vec);
% Average stator yoke eddy-current losses [W]
Res.FFT.Losses.Lamination.Stator.Yoke.EddyCurrent.Avg = mean(Res.FFT.Losses.Lamination.Stator.Teeth.EddyCurrent.Vec);
% Average stator eddy-current losses [W]
Res.FFT.Losses.Lamination.Stator.EddyCurrent.Total = Res.FFT.Losses.Lamination.Stator.Teeth.EddyCurrent.Avg + Res.FFT.Losses.Lamination.Stator.Yoke.EddyCurrent.Avg;

% Average stator total losses [W]
Res.FFT.Losses.Lamination.Stator.Total = Res.FFT.Losses.Lamination.Stator.Hysteresis.Total + Res.FFT.Losses.Lamination.Stator.EddyCurrent.Total;


%% Rotor average FFT. iron losses

% HYSTERESIS
% Average rotor hysteresis losses [W]
Res.FFT.Losses.Lamination.Rotor.Hysteresis.Total = mean(Res.FFT.Losses.Lamination.Rotor.Hysteresis.Vec);

% EDDY-CURRENT
% Average rotor eddy-current losses [W]
Res.FFT.Losses.Lamination.Rotor.EddyCurrent.Total = mean(Res.FFT.Losses.Lamination.Rotor.EddyCurrent.Vec);

% Average rotor total losses [W]
Res.FFT.Losses.Lamination.Rotor.Total = Res.FFT.Losses.Lamination.Rotor.Hysteresis.Total + Res.FFT.Losses.Lamination.Rotor.EddyCurrent.Total;


%% Model average FFT. iron losses
% Total model iron losses [W]
Res.FFT.Losses.Lamination.Total = Res.FFT.Losses.Lamination.Stator.Total + Res.FFT.Losses.Lamination.Rotor.Total;
