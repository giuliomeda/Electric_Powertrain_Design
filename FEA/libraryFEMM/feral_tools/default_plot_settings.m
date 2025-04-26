%% Plot properties

% Color
DefaultColors = {
'PhaseA',                          [255,0,0]/255;
'PhaseB',                          [34,139,34]/255;
'PhaseC',                          [0,0,255]/255;
'AxisD',                           [255,0,0]/255;
'AxisQ',                           [0,0,255]/255;
'FluxDensity',                     [0,0,255]/255;
'FluxDensityFund',                 [0,0,0]/255;
'TorqueDQ',                        [255,0,0]/255;
'TorqueMXW',                       [0,0,255]/255;
'TorqueHarm',                      [0,0,0]/255;
'BarPlot',                         [0,0,0]/255;
'BarPlotSkew',                     [255,0,0]/255;
'MTPA',                            [255,0,0]/255;    
'FW',                              [34,139,34]/255;
'MTPV',                            [0,0,255]/255;
'Ilim',                            [255,0,255]/255;
'FluxD0',                          [255,0,0]/255;
'FluxD',                           [0,0,0]/255;
'FluxQ0',                          [255,0,0]/255;
'FluxQ',                           [0,0,0]/255;
'IsoTorque',                       [0,0,255]/255;
'IsoFlux',                         [0,0,0]/255;
};

% Line style
DefaultLineStyles = {
'PhaseA',                          '-';
'PhaseB',                          '-';
'PhaseC',                          '-';
'AxisD',                           '-';
'AxisQ',                           '-';
'FluxDensity',                     '-';
'FluxDensityFund',                 '--';
'TorqueDQ',                        '-o';
'TorqueMXW',                       '-d';
'MTPA',                            '-';    
'FW',                              '-';
'MTPV',                            '-';
'Ilim',                            '-';
'IsoTorque',                       '-';
'IsoFlux',                         '-';
'FluxD0',                          '-';
'FluxD',                           '-';
'FluxQ0',                          '-';
'FluxQ',                           '-';
};

% Line width
DefaultLineWidths = {
'PhaseA',                          2;
'PhaseB',                          2;
'PhaseC',                          2;
'AxisD',                           2;
'AxisQ',                           2;
'FluxDensity',                     2;
'FluxDensityFund',                 2;
'TorqueDQ',                        2;
'TorqueMXW',                       2;
'MTPA',                            2;    
'FW',                              2;
'MTPV',                            2;
'Ilim',                            2;
'IsoTorque',                       1;
'IsoFlux',                         1;
'FluxD0',                          2;
'FluxD',                           0.5;
'FluxQ0',                          2;
'FluxQ',                           0.5;
};

% Legend
DefaultLegends = {
'PhaseA',                          'A';
'PhaseB',                          'B';
'PhaseC',                          'C';
'AxisD',                           'D-axis';
'AxisQ',                           'Q-axis';
'FluxDensity',                     'B_g(\theta_m)';
'FluxDensityFund',                 'B_g^1';
'TorqueDQ',                        'TorqueDQ';
'TorqueMXW',                       'TorqueMXW';
'MTPA',                            'MTPA';    
'FW',                              'FW';
'MTPV',                            'MTPV';
'Ilim',                            'Current limit';
'IsoTorque',                       'Const. Torque loci';
'IsoFlux',                         'Const. Flux loci';
'FluxD0',                          'I_q = 0';
'FluxD',                           '';
'FluxQ0',                          'I_d = 0';
'FluxQ',                           '';
};

% Axis label
DefaultLabels = {
'AngularPosition',                  'Angular position [deg]';
'AppPower',                         'Apparent power [VA]';
'CurrentAmplitude',                 'Current amplitude [A]';
'CurrentAngle',                     'Current angle [deg]';
'EddyCurrentLosses',                'Eddy current losses [W]';
'Efficiency',                       'Efficiency [%]';
'ElFrequency'                       'Electrical frequency [Hz]';
'ElSpeed',                          'Electrical speed [rad. el/s]';
'Flux',                             'Flux linkage [Vs]';
'FluxDensity',                      'Flux density [T]';
'FluxD',                            'd-axis flux linkage [Vs]';
'FluxQ',                            'q-axis flux linkage [Vs]';
'HarmonicOrder',                    'Harmonic order [-]';
'HysteresisLosses',                 'Hysteresis losses [W]';
'Id',                               'd-axis current [A]';
'Iq',                               'q-axis current [A]';
'InputPower',                       'Input Power [W]';
'IronLosses',                       'Iron losses [W]';
'JouleLosses',                      'Joule losses [W]';
'Losses',                           'Losses [W]';
'MechSpeed',                        'Mechanical speed [rad/s]';
'MechSpeedRPM',                     'Mechanical speed [rpm]';
'MechPower',                        'Mechanical power [W]';
'Phi',                              'Angle Phi [deg]';
'PowerFactor',                      'Power factor [-]';
'ReactPower',                       'Reactive power [Var]';
'RotorPositions',                   'Rotor position [deg]';
'Torque',                           'Torque [Nm]';
'Ud',                               'd-axis Voltage [V]';
'Uq',                               'q-axis Voltage [V]';
'Voltage',                          'Voltage [V]';
};


DefaultTitles = {
'Flux',                             'Flux linkage';
'TorqueMXW',                        'Maxwell Stress Tensor Torque';
'TorqueDQ',                         'DQ Torque';
'HarmonicOrder',                    'Harmonic order';
'AirgapFluxDensityWaveform',        'Air-gap flux density waveform, \theta_m =';
};

%% Font properties

DefaultFontNames = {
'Label',                          'Arial';
'Legend',                         'Arial';
'Axis',                           'Arial';
};

DefaultFontSizes = {
'Label',                          10;
'Legend',                         10;
'Axis',                           10;
};

DefaultFontWeights = {
'Label',                          'normal';
'Legend',                         'normal';
'Axis',                           'normal'
};