function [h, C] = plot_map(Map, PlotProp)

%% define some short variables
MTPA = Map.MTPA;
FW = Map.FW;
MTPV = Map.MTPV;

% Additional losses coefficient (losses)*k
if ~isfield(Map, 'CurrentLimit')
  Map.CurrentLimit = max([MTPA.CurrentAmplitude]);
end

if nargin < 2
  PlotProp = struct;
end

PlotProp = set_default_plot_settings(PlotProp);

hold on; grid on; box on;

%% current limit
h.Ilim = plot(Map.CurrentLimit*cosd(Map.CurrentAngleRange), Map.CurrentLimit*sind(Map.CurrentAngleRange), ...
  PlotProp.LineStyle.Ilim, ...
  'Color', PlotProp.Color.Ilim,  ...
  'linewidth', PlotProp.LineWidth.Ilim);

%% iso-torque curves
[C.torque, h.torque] = contour(Map.Id, Map.Iq, Map.TorqueDQ);
clabel(C.torque);

%% iso-flux curves
[C.flux, h.flux] = contour(Map.Id, Map.Iq, Map.Flux);
clabel(C.flux);

%% Plot
for kkk = 1:length(MTPA)
  
  if kkk == 1
    LegendVisibility = 'off';
  else
    LegendVisibility = 'on';
  end
  
  for StructNameVec = {'MTPA','FW','MTPV'}
    StructName = cell2mat(StructNameVec);
    
    if strcmp(StructNameVec, 'MTPA') && kkk == 1 % save the mtpa point
      x = unique([MTPA(1:end).Id]);
      y = unique([MTPA(1:end).Iq]);
    else
      eval(['x = ', StructName, '(kkk).(''Id'');']);
      eval(['y = ', StructName, '(kkk).(''Iq'');']);
    end
    h.(StructName)(kkk) = plot(x, y, ...
      eval(['PlotProp.LineStyle.', StructName]), ...
      'Color',  eval(['PlotProp.Color.', StructName]), ...
      'linewidth', eval(['PlotProp.LineWidth.', StructName]), ...
      'HandleVisibility', LegendVisibility);
  end
  
end



%% XY-label
h.LabelX = xlabel(PlotProp.Label.Id);
h.LabelY = ylabel(PlotProp.Label.Iq);

%% Legend

% labels
h.Legend = legend([h.Ilim, h.torque, h.flux, h.MTPA(1), h.FW(1), h.MTPV(1)], ...
  PlotProp.Legend.Ilim, ...
  PlotProp.Legend.IsoTorque, ...
  PlotProp.Legend.IsoFlux, ...
  PlotProp.Legend.MTPA, ...
  PlotProp.Legend.FW, ...
  PlotProp.Legend.MTPV);


%% Axis limits
xlim([min(min(Map.Id)) max(max(Map.Id))])
ylim([min(min(Map.Iq)) max(max(Map.Iq))])

axis equal

set_plot_properties

end % function