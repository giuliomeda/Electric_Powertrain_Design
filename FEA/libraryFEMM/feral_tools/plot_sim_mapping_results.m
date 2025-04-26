function plot_sim_mapping_results(Map, X, Y)

SD = Map.SimData;

if nargin < 2
  Y = {'Torque', 'MechPower', 'CurrentAmplitude'};
  X = repmat({'MechSpeedRPM'}, 1, 3);
end

%% Create figures folder if does not exist
if SD.SaveFigures == 1
  % create the figures folder
  if ~exist([SD.FiguresFolder, '/'], 'dir')
    mkdir(SD.FiguresFolder)
  end
end

%% Remove underscore from FileResultsPrefix (not necessary)
UnderscoreIdx = strfind(SD.FileResultsPrefix, '_');
FigurePrefix = SD.FileResultsPrefix;
FigurePrefix(UnderscoreIdx) = ' '; % replace underscore with space

if isfield(Map, 'MTPA') && isfield(Map, 'FW')
  
  %% Plot MTPA, FW, MTPV
  figure('Name', [FigurePrefix, ' Map'], 'NumberTitle','off')
  plot_map(Map, SD);
  save_pdf([SD.FiguresFolder, '\', SD.FileResultsPrefix, 'Map', '_', Map.DateString], SD.SaveFigures, SD.FigureWidth, SD.FigureHeight);
  
  %% Plot X vs y
  for plt = 1:length(Y)
    x = X{plt};
    y = Y{plt};
    PlotName = [x, ' vs ', y];
    FigName = [x, '_vs_', y];
    figure('Name', [FigurePrefix, PlotName], 'NumberTitle','off')
    plot_X_vs_Y(x, y, Map, SD);
    save_pdf([SD.FiguresFolder, '\', SD.FileResultsPrefix, FigName, '_', Map.DateString], SD.SaveFigures, SD.FigureWidth, SD.FigureHeight);
  end
  
end

%% Plot iso-torque and iso-flux
figure('Name', [FigurePrefix, ' Iso-Torque and Iso-Flux'], 'NumberTitle','off')
plot_isotorque_isoflux(Map, SD);
save_pdf([SD.FiguresFolder, '\', SD.FileResultsPrefix, 'Iso_torque_Iso_flux', '_', Map.DateString], SD.SaveFigures, SD.FigureWidth, SD.FigureHeight);

%% Plot FluxD vs Id
figure('Name', [FigurePrefix, ' FluxD vs Id'], 'NumberTitle','off')
plot_fluxD_vs_Id(Map, SD)
save_pdf([SD.FiguresFolder, '\', SD.FileResultsPrefix, 'FluxD_vs_Id', '_', Map.DateString], SD.SaveFigures, SD.FigureWidth, SD.FigureHeight);

%% Plot FluxQ vs Iq
figure('Name', [FigurePrefix, ' FluxQ vs Iq'], 'NumberTitle','off')
plot_fluxQ_vs_Iq(Map, SD)
save_pdf([SD.FiguresFolder, '\', SD.FileResultsPrefix, 'FluxQ_vs_Iq', '_', Map.DateString], SD.SaveFigures, SD.FigureWidth, SD.FigureHeight);

%% Plot FluxD vs Iq
figure('Name', [FigurePrefix, ' FluxD vs Iq'], 'NumberTitle','off')
plot_fluxD_vs_Iq(Map, SD)
save_pdf([SD.FiguresFolder, '\', SD.FileResultsPrefix, 'FluxD_vs_Iq', '_', Map.DateString], SD.SaveFigures, SD.FigureWidth, SD.FigureHeight);

%% Plot FluxQ vs Id
figure('Name', [FigurePrefix, ' FluxQ vs Id'], 'NumberTitle','off')
plot_fluxQ_vs_Id(Map, SD)
save_pdf([SD.FiguresFolder, '\', SD.FileResultsPrefix, 'FluxQ_vs_Id', '_', Map.DateString], SD.SaveFigures, SD.FigureWidth, SD.FigureHeight);

end % function