function s = draw_stator(MD)
%DRAW_STATOR draw a stator in FEMM

s = MD.Stator;

%% Define short variables
Dso = s.Geometry.OuterDiameter;
Dsi = s.Geometry.InnerDiameter;
wso = s.Geometry.SlotOpeningWidth;
hso = s.Geometry.SlotOpeningHeight;
hs = s.Geometry.SlotHeight;
wt = s.Geometry.ToothWidth;
hwed = s.Geometry.WedgeHeight;
hbi = Dso/2 - Dsi/2 - hs;
Qs = s.Geometry.Slots;
p = s.PolePairs;
SymFactor = 2*p / MD.SimPoles;
Qsim = Qs/SymFactor;
alphas = 2*pi/Qs;

%% Add material properties
add_materials2model(MD.Stator)

if strcmp(MD.Stator.Type, 'Outer')
  ParSign = 1;
  Dgap = Dsi;
  Dnogap = Dso;
elseif strcmp(MD.Stator.Type, 'Inner')
  ParSign = -1;
  Dgap = Dso;
  Dnogap = Dsi;
end
  

%% define default mesh sizes
if ~isfield(s,'Mesh')
  s.Mesh = struct;
end

if ~isfield(s.Mesh,'Slot')
  s.Mesh.Slot = hs/2;
end

if ~isfield(s.Mesh,'Lamination')
  s.Mesh.Lamination = wt/3;
end

if ~isfield(s.Mesh,'SlotOpening')
  s.Mesh.SlotOpening = min([wso, hso])/2;
end

% Az = 0 for external diameter
mi_deleteboundprop('Az=0') % to avoid multiple definitions
mi_addboundprop('Az=0', 0, 0, 0, 0, 0, 0, 0, 0, 0);

%% Computation of the coordinates of the slot points
alpha1 = asin(wso / Dgap);

x1 = Dgap/2 * cos(alpha1);
y1 = Dgap/2 * sin(alpha1);

ang0  = atan(y1/x1);
% alphat = alphas - 2 * ang0;
x0  = Dgap/2 * cos(alphas/2);
y0  = Dgap/2 * sin(alphas/2);

x3 = x1 + hso * ParSign;
y3 = y1;

x2 =  x1;
y2 = -y1;

x4 =  x3;
y4 = -y3;

xo5 = Dgap/2 + (hwed + hso * cos(alphas/2))*ParSign;
yo5 = wt/2;
rad5 = sqrt(xo5*xo5 + yo5*yo5);
ang5 = atan(yo5/xo5);
x5  = rad5 * cos(alphas/2 - ang5);
y5  = rad5 * sin(alphas/2 - ang5);

xo7 = Dgap/2 + hs*ParSign;
yo7 = wt/2;
rad7 = sqrt(xo7*xo7 + yo7*yo7);
ang7 = atan(yo7/xo7);
x7  = rad7 * cos(alphas/2 - ang7);
y7  = rad7 * sin(alphas/2 - ang7);

x6 =  x5;
y6 = -y5;

x8 =  x7;
y8 = -y7;

%% Draw slot geometry
draw_segment(x1, y1, x3, y3, '', '', 0, 1, 0, s.Group, 1, 1);
draw_segment(x3, y3, x5, y5, '', '', 0, 1, 0, s.Group, 0, 1);
draw_segment(x5, y5, x7, y7, '', '', 0, 1, 0, s.Group, 0, 1);
draw_segment(x2, y2, x4, y4, '', '', 0, 1, 0, s.Group, 1, 1);
draw_segment(x4, y4, x6, y6, '', '', 0, 1, 0, s.Group, 0, 1);
draw_segment(x6, y6, x8, y8, '', '', 0, 1, 0, s.Group, 0, 1);
draw_segment(x1, y1, x2, y2, '', '', 0, 1, 0, s.Group, 0, 0);
draw_segment(x3, y3, x4, y4, '', '', 0, 1, 0, s.Group, 0, 0);
draw_arc(x8, y8, x7, y7, 0, 0, 1, '', '', 0, s.Group, 0, 0);
draw_arc(x1, y1, x0, y0, 0, 0, 1, '', '', 0, s.Group, 0, 1);
draw_arc(x0, -y0, x1, -y1, 0, 0, 1, '', '', 0, s.Group, 1, 1);


%% Copy and rotate the slot
mi_selectgroup(s.Group);
mi_copyrotate( 0, 0, alphas*180/pi, Qsim-1);
mi_clearselected();

%% Align the stator side to horizontal axis
mi_selectgroup(s.Group);
mi_moverotate( 0, 0, alphas/2*180/pi);
mi_clearselected();


%% Add periodic-antiperiodic boundary condition
if mod(MD.SimPoles, 2) == 0 % periodic
  PerAperBClabel = 'stator_periodic_BC';
  BCtype = 4;
else
  PerAperBClabel = 'stator_antiperiodic_BC';
  BCtype = 5;
end

mi_addboundprop(PerAperBClabel, 0, 0, 0, 0, 0, 0, 0, 0, BCtype);


%% Draw stator periphery
if MD.SimPoles == s.PolePairs*2 % complete model
  draw_arc(Dnogap/2, 0, -Dnogap/2, 0, 0, 0, 1, '', 'Az=0', 0, s.Group, 1, 1)
  draw_arc(-Dnogap/2, 0, Dnogap/2, 0, 0, 0, 1, '', 'Az=0', 0, s.Group, 0, 0)
else
  xs1 = Dgap/2;
  ys1 = 0;
  xs2 = Dgap/2*cos(2*pi/SymFactor);
  ys2 = Dgap/2*sin(2*pi/SymFactor);
  xse1 = Dnogap/2;
  yse1 = 0;
  xse2 = Dnogap/2*cos(2*pi/SymFactor);
  yse2 = Dnogap/2*sin(2*pi/SymFactor);
  draw_arc(xse1, yse1, xse2, yse2, 0, 0, 1, '', 'Az=0', 0, s.Group, 1, 1);
  draw_segment(xs1, ys1, xse1, yse1, '', PerAperBClabel, 0, 1, 0, s.Group, 0, 0);
  draw_segment(xs2, ys2, xse2, yse2, '', PerAperBClabel, 0, 1, 0, s.Group, 0, 0);
end

%% Assign the label materials to the slots
MD = add_slotlabels2model(MD);

%% Assign the label to the stator lamination
radbi = Dnogap/2 - hbi/2 * ParSign;
draw_label(radbi * cos(alphas/2), radbi * sin(alphas/2), '', s.Mesh.Lamination, 0, '', 0, s.Group, 0)

end