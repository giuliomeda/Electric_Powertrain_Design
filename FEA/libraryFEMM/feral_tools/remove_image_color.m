function remove_image_color(ImageFile, RGBColor, AppendMod)
%%REMOVE_IMAGE_COLOR remove the pixels of an image with the color equal to
%   RGBColor and create a new file
% ImageFile is the the name of the image with path and extension
% RGBColor = [R G B] is a [1x3] array that define the color to remove
% AppendMod if equal to 1 if the suffix '_mod' is appended to the modified
% file

% Enable AppendMod if not defined
if nargin < 3
  AppendMod = 1;
end

% Set the suffix string
if AppendMod 
  StringTrasp = '_mod';
else
  StringTrasp = '';
end

% Get ImageFile data (path, name)
[ImagePath, ImageName, ~] = fileparts(ImageFile);

% Replace Image path if empty
if isempty(ImagePath)
  ImagePath = '.';
end

% Read image file
Image = imread(ImageFile);
% initialize alpha channel matrix (for transparency)
AlphaImage = ones(size(Image,1), size(Image,2));
  
% Get linear index of RGBColor pixels 
if isOctave && size(Image,3) == 1
  indx = find(Image == 1);
else
  indx = find(Image(:,:,1) == RGBColor(1) & Image(:,:,2) == RGBColor(2) & Image(:,:,3) == RGBColor(3));
end

% Alpha channel is transparent when is 0
% replace the ones with 0 in the position of the RGBColor pixels
AlphaImage(indx) = 0;

imwrite(Image, [ImagePath, '\', ImageName, StringTrasp, '.png'], 'Alpha', uint8(AlphaImage)*255);

end % function