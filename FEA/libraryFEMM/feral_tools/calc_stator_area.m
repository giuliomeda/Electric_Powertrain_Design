function [StatorArea, StatorTeethArea, StatorYokeArea] = calc_stator_area(Stator, Elements)

% Create short variables
s = Stator;
s.geo = Stator.Geometry;
ElmBarycenter = Elements.Barycenter;
ElmGroup = Elements.Group;
ElmArea = Elements.Area;

% Select the teeth elements
TeethRadius = s.geo.InnerDiameter/2 + s.geo.SlotHeight;
ElmBarycenterRadius = hypot(ElmBarycenter(:,1), ElmBarycenter(:,2));
TeethIndex = find(ElmGroup == s.Group & ElmBarycenterRadius <= TeethRadius);
% Select the stator yoke elements
YokeIndex = find(ElmGroup == s.Group & ElmBarycenterRadius > TeethRadius);
StatorArea = [0 0]; % initialize array

for ty = 1:2 % (teeth, yoke)
  
  if ty == 1
    StatorRegionIndex = TeethIndex;
  elseif ty == 2
    StatorRegionIndex = YokeIndex;
  end % if tt
  
  StatorRegionArea = ElmArea(StatorRegionIndex);
  StatorArea(ty) = sum(StatorRegionArea);
  
end

StatorTeethArea = StatorArea(1);
StatorYokeArea = StatorArea(2);
StatorArea = sum(StatorArea);

end % function