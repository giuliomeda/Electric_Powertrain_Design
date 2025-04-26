function plot_airgap_flux_density_spectrum(v, p, thetam, PlotProp) 
%PLOT_AIRGAPFLUXDENSITY_HARMONICS plot the harmonics of the structure v 
 
if nargin < 2  
  PlotProp = struct; 
end 
 
PlotProp = set_default_plot_settings(PlotProp); 

% find the array index of v.RotorPositions relative to thetam
thm_idx = find(v.RotorPositions == thetam);

% select the rotor position 
Bg = v.AirgapFluxDensity(thm_idx, :); 

hold on 
box on 
grid on 
 
% compute the fundamental 
[Bh, phih, h] = calc_fft(Bg); 
Bg1 = Bh(p+1); 
phi1 = phih(p+1); 
 
bar(h, Bh, 'FaceColor', PlotProp.Color.BarPlot); 
 
title([PlotProp.Title.AirgapFluxDensityWaveform, ' ', num2str(thetam), ' deg']) 
 
xlim([-1 max(h)+1]) 
 
%% XY-label 
xlabel(PlotProp.Label.HarmonicOrder) 
ylabel(PlotProp.Label.FluxDensity) 
 
set_plot_properties 
 
end % function 
