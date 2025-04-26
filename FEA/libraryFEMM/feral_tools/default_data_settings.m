

%% Set the default fields of the structure MD and SD
DefaultSettings = {
% model properties
'ACSolver',                             'Succ. Approx'; 
'ModelName',                            'ModelName';
'ModelPath',                            '.'; 
'ModelFrequency',                       0;
'ModelUnit',                            'meters';
'ModelType',                            'planar';
'ModelPrecision',                       1e-8;
'MeshMinAngle',                         30;
% 
% simulation options
'AddLossesCoeff',                       1;
'AirgapFluxDensityContourPoints',       720;
'AirgapFluxDensityFigure',              0;
'AirgapMeshSize',                       1e-3;
'CircName',                             'Islot';
'CloseFemm',                            1;
'CloseFigures',                         0;
'CompletePeriod',                       0;
'CurrentWaveformType',                  'sin';   
'CurrentWaveformArray',                 [0;0;0];  
'CurrentWaveformFormula',               {''}
'DecimalSymbol',                        'o';
'DeleteAuxFiles',                       1;
'DeleteTempFolder',                     0;
'DensityPlotGray',                      0;
'DensityPlotFolderName',               'sol';
'DensityPlotFolderPath',                '.';
'DensityPlotLegend',                    1;
'DensityPlotMax',                       2;
'DensityPlotMin',                       0;
'DensityPlotType',                      {'bmag'};
'DensityPlotZoom',                      [];
'DisableMagnets',                       {};
'DisplayProgress',                      1;
'EndWindingLength',                     0;
'EndWindingInductance',                 0;
'GetElmByElmProp',                      0;
'FiguresFolder',                        'figures';
'FigureWidth',                         12;
'FigureHeight',                        10;
'FileResultsPrefix',                    '';
'FormatNumber',                         '';
'HideContourPlot',                      0;
'ImageCrop',                            0;
'ImageExtension',                       'png';
'ImageSize',                            [0 0 0 0];
'ImageTransparency',                    1;
'IronLossesFFT',                        0;
'LossesTeethFactor',                    1;
'LossesYokeFactor',                     1;
'LossesRotorFactor',                    1;
'MagnetLossesFFT',                      0;
'MechSpeedRPM',                         1000;
'MinimizeFemm',                         1;
'MirrorHalfPeriod',                     1;
'MotionGroups',                         [];
'MoveMotionGroups',                     0;
'NewFemmInstance',                      1;
'PackFactor',                           1;
'PlotResults',                          0;
'PrevSolutionType',                     0;
'ResultsFolder',                        'results';
'RotorPositions',                       0;
'SaveAnsFiles',                         0; 
'SaveDensityPlots',                     0;
'SaveFigures',                          1;
'SaveMeshElementsValues',               0;
'SaveMeshNodes',                        0;
'SaveResults',                          1;
'SkewingAngles',                        0;
'SmartMesh',                            0;
'TempFileName',                         'temp';
'TempFolderName',                       'temp';
'TempFolderPath',                       '.';
'UsePreviousSolution',                  1;
'Warning',                              'on';
'WindingResistance',                    0;
}; 
