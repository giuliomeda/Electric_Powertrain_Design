proj = currentProject();
projectRoot = proj.RootFolder;
femPath = fullfile(projectRoot,'FEMM');


%% General data 
MD.ModelName = 'TeslaModel3_ElectricMotor_complete_1_test'; % .fem model name (deve essere uguale al nome del file femm) 
MD.ScaleFactor = 1;                                         % dipende da unità di misura all'interno del file FEMM
MD.StackLength = 134*MD.ScaleFactor; 
MD.PackFactor = 0.96; 
MD.PolePairs = 3; 
MD.Airgap = 0.7 * MD.ScaleFactor; 
MD.SimPoles = 6;

MD.ModelUnit = 'millimiters';
MD.AirgapMeshSize = 1;

%% Stator general data 
Stator.Type = 'External';
Stator.Group = 1000; 
Stator.PolePairs = MD.PolePairs; 
% Stator.Geometry.FirstSlotAngle = 0;
Stator.Geometry.Airgap = MD.Airgap; 
Stator.Geometry.StackLength = MD.StackLength; 
Stator.Geometry.Slots = 54;  
Stator.Geometry.OuterDiameter = 2*112.5*MD.ScaleFactor; 
Stator.Geometry.InnerDiameter = 2*75.65*MD.ScaleFactor; 
Stator.Geometry.ToothWidth = 4.35*MD.ScaleFactor; 
Stator.Geometry.SlotHeight = 18.85*MD.ScaleFactor; 
Stator.Geometry.SlotOpeningHeight = 0.85*MD.ScaleFactor; 
% Stator.Geometry.SlotOpeningWidth = 2.5*MD.ScaleFactor; 
% Stator.Geometry.WedgeHeight = 1.5*MD.ScaleFactor; 
%% Stator materials 
Stator.Material.Slot = mtrl_Copper(150); 
Stator.Material.Lamination = mtrl_M530_50A(50); 
% Stator.Material.SlotOpening = mtrl_Air; 
%% Stator mesh sizes 
% Stator.Mesh.Lamination = 1*MD.ScaleFactor; 
% Stator.Mesh.Slot = 1*MD.ScaleFactor; 
% Stator.Mesh.SlotOpening = 1*MD.ScaleFactor 
%% Stator winding properties 
Stator.Winding.SlotFillFactor = 0.38;  
Stator.Winding.ConductorsInSlot = 4; 
Stator.Winding.ParallelPaths = 3; 
Stator.Winding.SlotMatrix = load('SlotMatrixTM3.txt'); 
% Stator.Winding.CircName = 'Islot';

%% Rotor general data 
Rotor.Type = 'Internal';
Rotor.Group = 10; 
Rotor.IronGroup = 11;
Rotor.MagnetGroups = 12; % (for fft losses) 
Rotor.Alignment = 10; % [deg]
Rotor.PolePairs = MD.PolePairs; 
Rotor.Geometry.Airgap = MD.Airgap; 
Rotor.Geometry.StackLength = MD.StackLength; 
Rotor.Geometry.OuterDiameter = Stator.Geometry.InnerDiameter - 2*Stator.Geometry.Airgap; 
Rotor.Geometry.InnerDiameter = 2*34.75*MD.ScaleFactor; 
%% Rotor magnet dimensions 
% Rotor.Magnet.Geometry.Thickness = 2*MD.ScaleFactor; 
% Rotor.Magnet.Geometry.Width = 5*MD.ScaleFactor; 
%% Rotor materials 
Rotor.Material.Lamination = mtrl_M530_50A(50); 
Rotor.Material.Magnet = mtrl_N35SH(120); 
% Rotor.Material.Shaft = mtrl_Air; 
%% Rotor mesh sizes 
% Rotor.Mesh.Lamination = 1*MD.ScaleFactor; 
% Rotor.Mesh.Magnet = 1*MD.ScaleFactor; 
% Rotor.Mesh.Shaft = 1*MD.ScaleFactor; 

MD.Stator = Stator; 
MD.Rotor = Rotor; 
MD.MotionGroups = [Rotor.Group, Rotor.IronGroup, Rotor.MagnetGroups]; 

%% Set general simulation data 
...
% add here some simulation options