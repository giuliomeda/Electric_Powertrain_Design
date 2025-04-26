function plot_X_vs_Y(FieldX, FieldY, Map, PlotProp)


%% define some short variables
MTPA = Map.MTPA;
FW = Map.FW;
MTPV = Map.MTPV;



if nargin < 2
  PlotProp = struct;
end

PlotProp = set_default_plot_settings(PlotProp);

hold on;
grid on;
box on;

for kkk = 1:length(FW)
  
  if kkk == 1
    LegendVisibility = 'on';
  else
    LegendVisibility = 'off';
  end
  
  for StructNameVec = {'MTPA','FW','MTPV'}
    StructName = cell2mat(StructNameVec);
    eval(['x = ', StructName, '(kkk).(FieldX);']);
    eval(['y = ', StructName, '(kkk).(FieldY);']);
    
    plot(x, y, ...
      eval(['PlotProp.LineStyle.', StructName]), ...
      'Color',  eval(['PlotProp.Color.', StructName]), ...
      'linewidth', eval(['PlotProp.LineWidth.', StructName]), ...
      'HandleVisibility', LegendVisibility);     
  end
  
end

ylim(get_axis_lim([0 FW(end).(FieldY)], 0.2))

%% Legend
h.Legend = legend(PlotProp.Legend.MTPA, PlotProp.Legend.FW, PlotProp.Legend.MTPV);

%% XY-label
h.LabelX = xlabel(PlotProp.Label.(FieldX));
h.LabelY = ylabel(PlotProp.Label.(FieldY));

set_plot_properties

end % function