close all
clear all
clc

%% Define the motor under test
run('TeslaModel3_MODEL_DATA.m')

MD.ModelPath = fullfile(projectRoot,'DriveData','Motor','IPM_TeslaModel3','FEA');

%% Set simulation parameters
flagPlotFigures = 1; % 1=plot figures, 0= no plot
currentFolder   = fileparts(mfilename("fullpath"));
folderName      = fullfile(currentFolder,'results');

% Check if the folder exists. If not, create it
if ~exist(folderName, 'dir')
    mkdir(folderName);
end

%% Start simulations
SD.CurrentAmplitude     = 0; % [A]
SD.CurrentAngle         = 0; % [deg]
SD.RotorPositions       = [0:3:360]/MD.PolePairs; % [deg]
SD.FileResultsPrefix    = 'no_load';

[AvgValues, VecValues]  = sim_var_rotor_position(MD, SD);

%clear SD

%% Get BEMF

RPM = 1000; % Mechanical speed RPM [rpm]
wm = 2*pi*RPM/60; % Mechanical speed [rad/s]
we = wm*MD.PolePairs; % Electrical speed [el. rad/s]
freq = we/2/pi; % el. frequency [Hz]

VecValues.BemfA                   = wm*gradient(VecValues.FluxA, SD.RotorPositions*pi/180);
VecValues.BemfB                   = wm*gradient(VecValues.FluxB, SD.RotorPositions*pi/180);
VecValues.BemfC                   = wm*gradient(VecValues.FluxC, SD.RotorPositions*pi/180);
VecValues.BemfAB                  = VecValues.BemfA - VecValues.BemfB;
VecValues.BemfBC                  = VecValues.BemfB - VecValues.BemfC;
VecValues.BemfCA                  = VecValues.BemfC - VecValues.BemfA;


%% Plot figures

if flagPlotFigures
    plot_noloads_data(MD,SD,VecValues,folderName)
end