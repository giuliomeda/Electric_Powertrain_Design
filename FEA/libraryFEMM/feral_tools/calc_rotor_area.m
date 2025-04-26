function [RotorCoreArea, MagnetArea] = calc_rotor_area(Rotor, Elements)
 
% Create short variables
r = Rotor;
ElmGroup = Elements.Group;
ElmArea = Elements.Area;

% rotor core
RotorIndex = (ElmGroup == r.IronGroup);
RotorCoreArea = sum(ElmArea(RotorIndex));

% rotor magnet
MagnetIndex = find(any(ElmGroup == r.MagnetGroups, 2));
MagnetArea = sum(ElmArea(MagnetIndex));

end % function