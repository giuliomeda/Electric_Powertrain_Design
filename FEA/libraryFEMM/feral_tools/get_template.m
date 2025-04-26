function get_template(FileName, Path) 
%GET_MODEL_DATA create a minimal model data file 
%   Path is the path where to create the script 
 
% The dafault final path is the current one 
if nargin < 2
  Path = pwd; 
end 

[~, ~, ~, TemplatesPath] = get_feral_path();
 
% Name of the file to copy 
FileName = [FileName, '_template']; 
 
% Copy the original file into Path 
copyfile([TemplatesPath, '\', FileName, '.m'], [Path, '\', FileName, '_', datestr(clock, 30), '.m']) 
 
end % function