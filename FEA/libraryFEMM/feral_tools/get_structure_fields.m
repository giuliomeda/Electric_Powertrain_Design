function [NumOfFields, FieldNames] = get_structure_fields(Struct)
%%GET_STRUCTURE_FIELDS get the field names and number of the 
%   structure array Struct

FieldNames = fieldnames(Struct);
NumOfFields = numel(FieldNames);

end % function