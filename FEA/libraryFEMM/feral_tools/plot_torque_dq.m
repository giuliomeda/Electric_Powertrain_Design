function [h] = plot_torque_dq(v, PlotProp)
%PLOT_TORQUE_MXW plot the torque and add some labels

if nargin < 2 
  PlotProp = struct;
end

PlotProp = set_default_plot_settings(PlotProp);

box on
h.Tdq = plot(v.RotorPositions, v.TorqueDQ, PlotProp.LineStyle.TorqueDQ, 'color', PlotProp.Color.TorqueDQ, 'linewidth', PlotProp.LineWidth.TorqueDQ);
title(PlotProp.Title.TorqueDQ)
xlim([v.RotorPositions(1) v.RotorPositions(end)])
ylim(get_axis_lim([v.TorqueDQ v.TorqueMXW], 0.2))

%% XY-label
h.LabelX = xlabel(PlotProp.Label.RotorPositions);
h.LabelY = ylabel(PlotProp.Label.Torque);

set_plot_properties

end % function