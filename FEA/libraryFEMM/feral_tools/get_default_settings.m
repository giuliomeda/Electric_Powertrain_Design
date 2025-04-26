function [MD, SD] = get_default_settings(SettingsType)
%GET_SIMULATIONA_DATA Generate the complete simulation data structure on
%   command window.

if nargin < 1
  SettingsType = 'all';
end

%% Initilize the structures MD and SD
MD = struct;
SD = MD;

if strcmp(SettingsType, 'all') || strcmp(SettingsType, 'simulation')

  % Load the default simulation settings
  default_data_settings
  [MD, SD] = set_default_data_settings(MD, SD, DefaultSettings);
  
end

if strcmp(SettingsType, 'all') || strcmp(SettingsType, 'plot')
  % Load the default plot settings
  [MD, SD] = set_default_plot_settings(MD, SD);
  
end

end % function
