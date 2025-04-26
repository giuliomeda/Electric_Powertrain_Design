for sk = 1 : length(SD.SkewingAngles)
  
  MagnetIdx = find(any(ElmGroup == r.MagnetGroups, 2));
  MagnetAz = Skew.ElmAz_mat(:,MagnetIdx,sk);
  MagnetBx = Skew.ElmBx_mat(:,MagnetIdx,sk);
  MagnetBy = Skew.ElmBy_mat(:,MagnetIdx,sk);
  
  if SD.MirrorHalfPeriod == 1
    MagnetAz = [MagnetAz; MagnetAz];
  end
  
  % compute fft of Az and then Jeddy
  NN = size(MagnetAz,1);
  sigmaPM = r.Material.Magnet.ElConductivity; % [Ohm.m]
  MagnetAzFFT = fft(MagnetAz)*2/NN;
  JeFFT = -1i*sigmaPM*2*pi*repmat(ElFreqVec',1,size(Az,2)).*MagnetAzFFT;
  MeshElementArch = 0;
  
  for MagIdx = r.MagnetGroups
    ThisMagnetElm = ElmGroup(MagnetIdx) == MagIdx;
    ThisMagnetElmIdx = find(ThisMagnetElm);
    ThisMagnetElmArea = MagnetElmArea(ThisMagnetElmIdx);
    ThisMagnetArea = sum(ThisMagnetElmArea);
    Javg = JeFFT(:,ThisMagnetElmIdx)*ThisMagnetElmArea/ThisMagnetArea;
    JeFFT = JeFFT - Javg*ThisMagnetElm';
    MeshElementArch = MeshElementArch + size(MagnetIdx,2);
    
  if SD.SaveMeshElementsValues == 1
    Res.Mesh.Elements.Rotor.Magnet(MagIdx).Number = size(MagnetIdx,2);
    Res.Mesh.Elements.Rotor.Magnet(MagIdx).Az(:,:,sk) = MagnetAz;
    Res.Mesh.Elements.Rotor.Magnet(MagIdx).FluxDensityX(:,:,sk) = MagnetBx;
    Res.Mesh.Elements.Rotor.Magnet(MagIdx).FluxDensityY(:,:,sk) = MagnetBy;
    Res.Mesh.Elements.Rotor.Magnet(MagIdx).Coordinates.Nodes = ElmNodes(MagnetIdx,:);
    Res.Mesh.Elements.Rotor.Magnet(MagIdx).Coordinates.Barycenter = ElmBarycenter(MagnetIdx,:);
    Res.Mesh.Elements.Rotor.Magnet(MagIdx).Area = ElmArea(MagnetIdx,:);
    Res.Mesh.Elements.Rotor.Magnet(MagIdx).Group = ElmGroup(MagnetIdx,:);
  end
    
  end
  
  MagnetLosses(sk) = SymFactor/(2*sigmaPM)*sum(abs(JeFFT).^2*MagnetElmVolume); % [W]
  
end % for sk = 1 : length(SD.SkewingAngles)

Res.FFT.Losses.Magnet.Vec = MagnetLosses;
Res.FFT.Losses.Magnet.Total = mean(MagnetLosses);
