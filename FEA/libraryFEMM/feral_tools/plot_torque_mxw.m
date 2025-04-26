function [h] = plot_torque_mxw(v, PlotProp)
%PLOT_TORQUE_MXW plot the torque and add some labels

if nargin < 2 
  PlotProp = struct;
end

PlotProp = set_default_plot_settings(PlotProp);

box on
h.Tmxw = plot(v.RotorPositions, v.TorqueMXW, PlotProp.LineStyle.TorqueMXW, 'color', PlotProp.Color.TorqueMXW, 'linewidth', PlotProp.LineWidth.TorqueMXW);

xlim([v.RotorPositions(1) v.RotorPositions(end)])
ylim(get_axis_lim([v.TorqueDQ v.TorqueMXW], 0.2))

if ~isempty(PlotProp.Title.TorqueMXW)
  title(PlotProp.Title.TorqueMXW)
end

%% XY-label
h.LabelX = xlabel(PlotProp.Label.RotorPositions);
h.LabelY = ylabel(PlotProp.Label.Torque);

set_plot_properties

end % function