close all
clear all
clc

%% Define the motor under test
run('TeslaModel3_MODEL_DATA.m')

MD.ModelPath = fullfile(projectRoot,'DriveData','Motor','IPM_TeslaModel3','FEA');

%% Set simulation parameters

currentFolder = fileparts(mfilename("fullpath"));
folderName = fullfile(currentFolder,'results');

SD.CurrentAmplitude = 0; % [A]
SD.CurrentAngle     = 0; % [deg]
SD.PlotResults      = 1;

% move rotor group graphically
SD.MoveMotionGroups         = 1;
SD.SaveDensityPlots         = 1;
SD.DensityPlotGray         = 0;
SD.DensityPlotLegend       = 0;
SD.DensityPlotMax          = 2;
SD.DensityPlotMin          = 0;
SD.HideContourPlot         = 0;
SD.ImageCrop               = 1;
SD.ImageExtension          = 'png';
SD.ImageTransparency       = 1; % don't show the legend
SD.ShowFluxLines           = 0; % command for showing the lines of the magnetic field
SD.ShowDirectionsFluxLines = 0; % command for showing the directions of the magnetic field lines


%% run simulation "as is"

res = sim_var_rotor_position(MD,SD);

%% estimate alignment

% angular displacement

if abs(res.FluxD-res.FluxA)>0.005 || abs(res.FluxQ)>1e-04

    delta_lambda_E       = (atan2(res.FluxQ,res.FluxD))*(180/pi); % angular displacement
    delta_lambda         = -delta_lambda_E/MD.PolePairs;
    MD.Rotor.Alignment   = MD.Rotor.Alignment+delta_lambda;

    res = sim_var_rotor_position(MD, SD);


end

textToDisp = sprintf("The rotor alignment is %f",MD.Rotor.Alignment);
disp(textToDisp);

clear SD
return
%% remove folders

folderToRemove = fullfile(currentFolder, 'results');
rmdir(folderToRemove, 's');

folderToRemove = fullfile(currentFolder, 'temp');
rmdir(folderToRemove, 's');
