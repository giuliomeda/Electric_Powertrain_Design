function [MainPath, ToolsPath, MaterialsPath, TemplatesPath] = get_feral_path()

% Get this script path 
ToolsPath = fileparts(mfilename('fullpath')); 

LastSlashIndex = strfind(ToolsPath, 'feral_tools') - 2;

DirSymbol = ToolsPath(LastSlashIndex+1);

MainPath = ToolsPath(1:LastSlashIndex);

MaterialsPath = [MainPath, DirSymbol, 'feral_materials'];

TemplatesPath = [MainPath, DirSymbol, 'feral_templates'];

end % function