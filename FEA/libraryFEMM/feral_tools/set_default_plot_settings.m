function [MD, SD] = set_default_plot_settings(MD, SD)
%%SET_DEFAULT_PLOT_SETTINGS assign the default plot settings to the missing
%   field of Struct

if nargin < 2
  SD = MD;
end

%% load default plot settings
default_plot_settings

PlotPropFields = {'Color', 'LineStyle', 'LineWidth', 'Legend', 'FontName', 'FontSize', 'FontWeight', 'Label', 'Title'};

for pp = 1:length(PlotPropFields)

  FieldName = PlotPropFields{pp};
  if ~isfield(MD, FieldName)
      eval(['MD.', FieldName, ' = struct;']);
  end
  if ~isfield(SD, FieldName)
      eval(['SD.', FieldName, ' = MD.', FieldName, ';']);
  end
end


%% Set default plot properties
[MD.Color, SD.Color] = set_default_data_settings(MD.Color, SD.Color, DefaultColors);
[MD.LineStyle, SD.LineStyle] = set_default_data_settings(MD.LineStyle, SD.LineStyle, DefaultLineStyles);
[MD.LineWidth, SD.LineWidth] = set_default_data_settings(MD.LineWidth, SD.LineWidth, DefaultLineWidths);
[MD.Legend, SD.Legend] = set_default_data_settings(MD.Legend, SD.Legend, DefaultLegends);
[MD.FontName, SD.FontName] = set_default_data_settings(MD.FontName, SD.FontName, DefaultFontNames);
[MD.FontSize, SD.FontSize] = set_default_data_settings(MD.FontSize, SD.FontSize, DefaultFontSizes);
[MD.FontWeight, SD.FontWeight] = set_default_data_settings(MD.FontWeight, SD.FontWeight, DefaultFontWeights);
[MD.Label, SD.Label] = set_default_data_settings(MD.Label, SD.Label, DefaultLabels);
[MD.Title, SD.Title] = set_default_data_settings(MD.Title, SD.Title, DefaultTitles);

end
