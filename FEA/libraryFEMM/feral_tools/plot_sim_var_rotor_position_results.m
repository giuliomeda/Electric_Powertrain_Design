function plot_sim_var_rotor_position_results(Res, Vec)
%PLOT SIM_VAR_ROTOR_POSITION results plot all the results of the 
%   sim_var_rotor_position procedure

MD = Res.ModelData;
SD = Res.SimData;

% add skew to filename
if length(SD.SkewingAngles) > 1
  SkewString = 'skew_';
else
  SkewString = '';
end

SD.FileResultsPrefix = [SD.FileResultsPrefix, SkewString];

%% Create figures folder if does not exist
if SD.SaveFigures == 1
  % create the figures folder
  if ~exist([SD.FiguresFolder, '/'], 'dir')
    mkdir(SD.FiguresFolder)
  end
end

%% Add 'complete' to the extended plot names
if SD.CompletePeriod
  CompletePlotString = '_complete';
else
  CompletePlotString = '';
end

%% Remove underscore from FileResultsPrefix (not necessary) 
UnderscoreIdx = strfind(SD.FileResultsPrefix, '_');
FigurePrefix = SD.FileResultsPrefix;
FigurePrefix(UnderscoreIdx) = ' '; % replace underscore with space

%% Plot flux linkage waveform (ABC)
figure('Name', [FigurePrefix, ' Flux linkages ABC'], 'NumberTitle','off');
plot_flux_linkage_waveform(Vec, 1, SD);
save_pdf([SD.FiguresFolder, '/', SD.FileResultsPrefix, 'flux_linkages_ABC', CompletePlotString, '_', Res.DateString], SD.SaveFigures, SD.FigureWidth, SD.FigureHeight);

%% Plot flux linkage waveform (DQ)
figure('Name', [FigurePrefix, ' Flux linkages DQ'], 'NumberTitle','off');
plot_flux_linkage_waveform(Vec, 2, SD);
save_pdf([SD.FiguresFolder, '/', SD.FileResultsPrefix, 'flux_linkages_DQ', CompletePlotString, '_', Res.DateString], SD.SaveFigures, SD.FigureWidth, SD.FigureHeight);

%% Plot flux linkage spectrum
figure('Name', [FigurePrefix, ' Flux linkage spectrum'], 'NumberTitle','off');
plot_flux_linkage_spectrum(Vec, SD);
save_pdf([SD.FiguresFolder, '/', SD.FileResultsPrefix, 'flux_linkage_spectrum', CompletePlotString, '_', Res.DateString], SD.SaveFigures, SD.FigureWidth, SD.FigureHeight);

%% Plot air-gap flux density
for thm = SD.AirgapFluxDensityFigure % generate a figure for each element of 'AirgapFluxDensityFigure'
  
  if ~isempty(intersect(Vec.RotorPositions, thm))
  
  StringThm = ['_thm_', number2string(thm, SD.DecimalSymbol), '_deg'];
  
  % one mechanical period
  figure('Name', [FigurePrefix, ' Airgap flux density', [' thm = ', num2str(thm), ' deg,'], ' 360 mech. deg'], 'NumberTitle','off');
  plot_airgap_flux_density_waveform(Vec, MD.PolePairs, thm, SD);
  save_pdf([SD.FiguresFolder, '/', SD.FileResultsPrefix, 'airgap_flux_density', StringThm, '_360_mechdeg', '_', Res.DateString], SD.SaveFigures, SD.FigureWidth, SD.FigureHeight);
  
  % one electric period
  figure('Name', [FigurePrefix, ' Airgap flux density', StringThm, ' 360 el. deg'], 'NumberTitle','off');
  plot_airgap_flux_density_waveform(Vec, MD.PolePairs, thm, SD);
  xlim([0 360/MD.PolePairs])
  save_pdf([SD.FiguresFolder, '/', SD.FileResultsPrefix, 'airgap_flux_density', StringThm, '_360_eldeg', '_', Res.DateString], SD.SaveFigures, SD.FigureWidth, SD.FigureHeight);
  
  % flux density spectrum
  figure('Name', [FigurePrefix, ' Airgap flux density spectrum', StringThm], 'NumberTitle','off');
  plot_airgap_flux_density_spectrum(Vec, MD.PolePairs, thm, SD)
  save_pdf([SD.FiguresFolder, '/', SD.FileResultsPrefix, 'airgap_flux_density_spectrum', StringThm, '_', Res.DateString], SD.SaveFigures, SD.FigureWidth, SD.FigureHeight);
  
  else
    warning off backtrace
    warning(['The flux density plot for AirgapFluxDensityFigure = ', num2str(thm), ' deg has been skipped. The angle does not belong to RotorPositions'])
    warning on backtrace
  end
  
end % for thm = SD.AirgapFluxDensityFigure


%% Plot torque waveform
figure('Name', [FigurePrefix, ' Torque ', CompletePlotString], 'NumberTitle','off');
hold on
box on
grid on
plot_torque_mxw(Vec, SD);
plot_torque_dq(Vec, SD);
title([])
h.Legend = legend('TorqueMXW', 'TorqueDQ');
set(h.Legend, ...
  'Fontname', SD.FontName.Legend, ...
  'FontSize', SD.FontSize.Legend, ...
  'Fontweight', SD.FontWeight.Legend);
save_pdf([SD.FiguresFolder, '/', SD.FileResultsPrefix, 'torque', CompletePlotString, '_', Res.DateString], SD.SaveFigures, SD.FigureWidth, SD.FigureHeight);

%% Plot TorqueMXW spectrum
figure('Name', [FigurePrefix, ' Maxwell stress tensor spectrum'], 'NumberTitle','off');
plot_torque_spectrum(Vec, SD);
save_pdf([SD.FiguresFolder, '/', SD.FileResultsPrefix, 'torque_spectrum', CompletePlotString, '_', Res.DateString], SD.SaveFigures, SD.FigureWidth, SD.FigureHeight);

end % function