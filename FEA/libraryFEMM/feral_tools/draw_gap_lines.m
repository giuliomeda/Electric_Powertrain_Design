function draw_gap_lines( MD, AirgapMeshSize, SlidingBandMinArcDeg)
%%DRAW_GAP_LINES draw the sliding band lines and add the labels

%% Define some short variables
s = MD.Stator;
s.geo = MD.Stator.Geometry;
r = MD.Rotor;
r.geo = MD.Rotor.Geometry;
Airgap = MD.Airgap;
SymFactor = 2*MD.PolePairs/MD.SimPoles;
PeriodAngle = 2*pi/SymFactor;
PolePitchAngle = pi/MD.PolePairs;

if strcmp(MD.Rotor.Type, 'Internal') || strcmp(MD.Stator.Type, 'External')
  
  TypeSign = 1;
  
  if isfield(MD.Rotor.Geometry, 'DiameterHandle')
    RotorRadiusGap = MD.Rotor.Geometry.DiameterHandle/2;
  else
    RotorRadiusGap = r.geo.OuterDiameter/2;
  end
  
  if isfield(MD.Stator.Geometry, 'DiameterHandle')
    StatorRadiusGap = MD.Stator.Geometry.DiameterHandle/2;
  else
    StatorRadiusGap = s.geo.InnerDiameter/2;
  end
    
elseif strcmp(MD.Rotor.Type, 'External') || strcmp(MD.Stator.Type, 'Internal')
    
  TypeSign = -1;
  
  if isfield(MD.Rotor.Geometry, 'DiameterHandle')
    RotorRadiusGap = MD.Rotor.Geometry.DiameterHandle/2;
  else
    RotorRadiusGap = r.geo.InnerDiameter/2;  
  end
  
  if isfield(MD.Stator.Geometry, 'DiameterHandle')
    StatorRadiusGap = MD.Stator.Geometry.DiameterHandle/2;
  else
    StatorRadiusGap = s.geo.OuterDiameter/2;
  end
  
end
  
% set rotor handle
RotorHandle = RotorRadiusGap + Airgap/3 * TypeSign;

% set stator handle
StatorHandle = StatorRadiusGap - Airgap/3 * TypeSign; 

%% Set missing values
if nargin < 2
  AirgapMeshSize = gap/3/2;
end

if nargin < 3
  SlidingBandMinArcDeg = 1;
end

%% Scheme
% x                                  x
% |                                  |
% |              STATOR              |
% S3---------------------------------S2 <-- stator radius gap
% |         label stator gap         |
% S4---------------------------------S1 <-- stator handle
%
%                  GAP
%
% R3--------------------------------R2 <-- rotor handle
% |          label rotor gap         |
% R4--------------------------------R1 <-- rotor radius gap
% |               ROTOR              |
% |                                  |
% x                                  x
%          <-----PeriodAngle---------0

%% Add boundary conditions (BCs)

% set BC names
if SymFactor == 1 || mod(MD.SimPoles, 2) == 0
  GapBdryFormat = 4;
  SB_BdryFormat = 6;
  LabelGapBC = {'GapPeriodic_1', 'GapPeriodic_2'};
else
  GapBdryFormat = 5;
  SB_BdryFormat = 7;
  LabelGapBC = {'GapAntiPeriodic_1', 'GapAntiPeriodic_2'};
end

% Sliding band properties
mi_addboundprop('GapSlidingBand', 0, 0, 0, 0, 0, 0, 0, 0, SB_BdryFormat, 0, 0);

% define stator coordinates
xS1 = StatorHandle;
yS1 = 0;

xS2 = StatorRadiusGap;
yS2 = 0;

xS3 = StatorRadiusGap * cos(PeriodAngle);
yS3 = StatorRadiusGap * sin(PeriodAngle);

xS4 = StatorHandle * cos(PeriodAngle);
yS4 = StatorHandle * sin(PeriodAngle);

% define rotor coordinates
xR1 = RotorRadiusGap;
yR1 = 0;

xR2 = RotorHandle;
yR2 = 0;

xR3 = RotorHandle * cos(PeriodAngle);
yR3 = RotorHandle * sin(PeriodAngle);

xR4 = RotorRadiusGap * cos(PeriodAngle);
yR4 = RotorRadiusGap * sin(PeriodAngle);

if SymFactor ~= 1 % if periodic BC are used
  
  % periodic/antiperiodic
  mi_deleteboundprop(LabelGapBC{1});
  mi_addboundprop(LabelGapBC{1}, 0, 0, 0, 0, 0, 0, 0, 0, GapBdryFormat, 0, 0);
  mi_deleteboundprop(LabelGapBC{2});
  mi_addboundprop(LabelGapBC{2}, 0, 0, 0, 0, 0, 0, 0, 0, GapBdryFormat, 0, 0);
  
  
  draw_segment(xS1, yS1, xS2, yS2, '', LabelGapBC{1}, 0, 1, 1, s.Group, 1, 0);
  draw_segment(xS3, yS3, xS4, yS4, '', LabelGapBC{1}, 0, 1, 1, s.Group, 0, 1);
  
  draw_arc(xS1, yS1, xS4, yS4, 0, 0, SlidingBandMinArcDeg, '', 'GapSlidingBand', 1, s.Group, 0, 0);
  
  draw_segment(xR1, yR1, xR2, yR2, '', LabelGapBC{2}, 0, 1, 1, r.Group, 0, 1);
  draw_segment(xR3, yR3, xR4, yR4, '', LabelGapBC{2}, 0, 1, 1, r.Group, 1, 0);
  
  % draw rotor arc
  draw_arc(xR2, yR2, xR3, yR3, 0, 0, SlidingBandMinArcDeg, '', 'GapSlidingBand', 1, r.Group, 0, 0);
  
else % full model
 
  % stator arc
  % top
  draw_arc(xS1, yS1, -xS1, yS1, 0, 0, SlidingBandMinArcDeg, '', 'GapSlidingBand', 1, s.Group, 1, 1);
  % bottom
  draw_arc(-xS1, yS1, xS1, yS1, 0, 0, SlidingBandMinArcDeg, '', 'GapSlidingBand', 1, s.Group, 0, 0);
  
  % rotor arc
  % top
  draw_arc(xR2, yR2, -xR2, yR2, 0, 0, SlidingBandMinArcDeg, '', 'GapSlidingBand', 1, r.Group, 1, 1);
  % bottom
  draw_arc(-xR2, yR2, xR2, yR2, 0, 0, SlidingBandMinArcDeg, '', 'GapSlidingBand', 1, r.Group, 0, 0);
  
  % set no mesh in the middle airgap
  MiddleAirgap = StatorRadiusGap - Airgap/2 * TypeSign;
  xlb = MiddleAirgap * cos(PolePitchAngle/2);
  ylb = MiddleAirgap * sin(PolePitchAngle/2);
  draw_label(xlb, ylb, '<No Mesh>', 0, 0, 0, 0, 0, 0)
  
end

%% add band materials
% stator gap label
StatorGapRadiusLabel = StatorRadiusGap - Airgap/6 * TypeSign;
xlb = StatorGapRadiusLabel * cos(PolePitchAngle/2);
ylb = StatorGapRadiusLabel * sin(PolePitchAngle/2);
draw_label(xlb, ylb, 'Air', AirgapMeshSize, 0, '', 0, 0, 0);

% rotor gap label
RotorGapRadiusLabel = RotorRadiusGap + Airgap/6 * TypeSign;
xlb = RotorGapRadiusLabel * cos(PolePitchAngle/2);
ylb = RotorGapRadiusLabel * sin(PolePitchAngle/2);
draw_label(xlb, ylb, 'Air', AirgapMeshSize, 0, '', 0, r.Group, 0);

end % function