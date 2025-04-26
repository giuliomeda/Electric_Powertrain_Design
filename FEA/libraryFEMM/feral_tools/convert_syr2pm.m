function Map = convert_syr2pm(Map)
%%CONVERT_IPM2SYR convert the map from Syr reference frame (fluxPM along -q-axis)
%   to IPM reference frame (flux PM along d-axis)

% Save initial values
Id = Map.Id;
Iq = Map.Iq;
fluxD = Map.FluxD;
fluxQ = Map.FluxQ;

%% Get Map fields
[NumOfFields, FieldNames] = get_structure_fields(Map);

%% Rotate all the maps
for fld = 1:NumOfFields 

  FieldContent = Map.(FieldNames{fld});
  
  % Check if the content is a map with the same size of Map.Id and Map.Iq
  % and rotate the maps
  if size(FieldContent, 1) == size(Map.Iq, 1) && size(FieldContent, 2) == size(Map.Iq, 2) % is a map
    
    Map.(FieldNames{fld}) = rot90(FieldContent);
    
  end
    
end

%% Exception for current and flux linkages (rotated and inverted)
Map.Id = rot90(-Iq);
Map.Iq = rot90(Id);
[Map.CurrentAngle, Map.CurrentAmplitude] = cart2pol(Map.Id, Map.Iq);
Map.CurrentAngle = Map.CurrentAngle * 180/pi;
Map.Id_vec = Map.Id(1,:);
Map.Iq_vec = Map.Iq(:,1);

Map.FluxD = rot90(-fluxQ);
Map.FluxQ = rot90(fluxD);

end