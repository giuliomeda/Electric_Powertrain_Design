function [h] = plot_airgap_flux_density_waveform(v, p, thetam, PlotProp)
%PLOT_AIRGAPFLUXDENSITY_WAVEFORM plot the normal flux density within the air-gap

if nargin < 4
  PlotProp = struct;
end

PlotProp = set_default_plot_settings(PlotProp);

if size(v.AirgapFluxDensity, 3) > 1 % skew
  idx_noskew = (size(v.AirgapFluxDensity,3)-1)/2+1;
else
  idx_noskew = 1;
end

% find the array index of v.RotorPositions relative to thetam
thm_idx = find(v.RotorPositions == thetam);

% select the rotor position
Bg = v.AirgapFluxDensity(thm_idx, :, idx_noskew);

% compute the fundamental
[Bh, phih] = calc_fft(Bg);
Bg1 = Bh(p+1);
phi1 = phih(p+1);

% plot
box on
hold on
grid on
h.Bg = plot(v.AirgapFluxDensityAngle, Bg, PlotProp.LineStyle.FluxDensity, 'color', PlotProp.Color.FluxDensity, 'linewidth', PlotProp.LineWidth.FluxDensity);
h.Bg1 = plot(v.AirgapFluxDensityAngle, Bg1*cos((v.AirgapFluxDensityAngle*pi/180)*p + phi1), PlotProp.LineStyle.FluxDensityFund, 'color', PlotProp.Color.FluxDensityFund, 'linewidth', PlotProp.LineWidth.FluxDensityFund);
title([PlotProp.Title.AirgapFluxDensityWaveform, ' ', num2str(thetam), ' deg'])
xlim([min(v.AirgapFluxDensityAngle) max(v.AirgapFluxDensityAngle)])
ylim(get_axis_lim(Bg, 0.2))

%% Legend
h.Legend = legend(PlotProp.Legend.FluxDensity, PlotProp.Legend.FluxDensityFund);

%% XY-label
h.LabelX = xlabel(PlotProp.Label.AngularPosition);
h.LabelY = ylabel(PlotProp.Label.FluxDensity);
set(gca, 'xtick', [0:30:360])

set_plot_properties

end % function