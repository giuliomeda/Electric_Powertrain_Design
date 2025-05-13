close all
clear all
clc

%% Define the motor under test
run('TeslaModel3_MODEL_DATA.m')

MD.ModelPath = fullfile(projectRoot,'DriveData','Motor','IPM_TeslaModel3','FEA');

%% Set simulation parameters

currentFolder   = fileparts(mfilename("fullpath"));
folderName      = fullfile(currentFolder,'results');

SD.CurrentAmplitude = 0; % [A]
SD.CurrentAngle     = 0; % [deg]

%% No load simulations
for w = 0:30:180

   SD.RotorPositions          = w/MD.PolePairs;
   SD.MoveMotionGroups        = 1; 
   SD.SaveDensityPlots        = 1;
   SD.DensityPlotGray         = 0;
   SD.DensityPlotLegend       = 0;
   SD.DensityPlotMax          = 0;
   SD.DensityPlotMin          = 2;
   SD.HideContourPlot         = 0;
   SD.ImageCrop               = 1;
   SD.ImageExtension          = 'png';
   SD.ImageTransparency       = 1; % don't show the legend

   SD.ShowFluxLines           = 1; % command for showing the lines of the magnetic field
   SD.ShowDirectionsFluxLines = 1; % command for showing the directions of the magnetic field lines


   sim_var_rotor_position(MD, SD);

end

clear SD