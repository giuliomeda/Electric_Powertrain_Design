function Struct = append_data_to_structure(DataToAppend, Struct, StructIndex, FieldIndex)
%%APPEND_DATA_TO_STRUCTURE append the data contained in DataToAppend to the
%   structure array Struct. 
%   StructIndex is the index of the structure array. Ex. Struct(StructIndex).fiel.
%   FieldIndex is an array which contains the element indices of the DataToAppend
%   fields to select. For example to append only the first element of DataToAppend
%   to Struc(1), it has to be set to 1, otherwise all the array is appended


if nargin < 3
  StructIndex = 1;
end

if nargin < 4
  FieldIndex = [];
end

[NumOfFields, FieldNames] = get_structure_fields(DataToAppend);

for jj = 1 : NumOfFields % for each field
  
  % Initialize the undefined fields
  if ~isfield(Struct(StructIndex), FieldNames{jj}) % create an empty field if does not exist
    
    if iscell(DataToAppend.(FieldNames{jj})) % check if the field is cell or mat
      Struct(StructIndex).(FieldNames{jj}) = {}; % create an empty cell
    else
      Struct(StructIndex).(FieldNames{jj}) = []; % create an empthy array
    end
    
  end
  
  % Select only the given indices (if defined)
  if ~isempty(FieldIndex) && iscell(DataToAppend.(FieldNames{jj})) % select the cell indices
    Data = DataToAppend.(FieldNames{jj}){FieldIndex}; 
  elseif ~isempty(FieldIndex) && ismatrix(DataToAppend.(FieldNames{jj})) % select the array indices
    Data = DataToAppend.(FieldNames{jj})(FieldIndex);
  else % full cell or array
    Data = DataToAppend.(FieldNames{jj});
  end
  
  % Append value
  if iscell(Data) % append to cell
    Struct(StructIndex).(FieldNames{jj}) = {Struct(StructIndex).(FieldNames{jj}), Data};
  else % append to array
    Struct(StructIndex).(FieldNames{jj}) = [Struct(StructIndex).(FieldNames{jj}), Data];
  end
end


end % function
