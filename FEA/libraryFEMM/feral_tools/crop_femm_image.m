function ImageFileCropped = crop_femm_image(ImageFile, AutoCrop, ImageSize, CroppedImageExtension)

% load the package image 
if isOctave
  pkg load image
end

if nargin < 4
  CroppedImageExtension = '.png';
end

[ImagePath, ImageName, ~] = fileparts(ImageFile);

if isempty(ImagePath)
  ImagePath = '.';
end

% read image file
Image = imread(ImageFile);


if AutoCrop
  
  % get linear indx of white pixels: RGB = [255 255 255]
  if isOctave && size(Image,3) == 1
    indx = find(Image == 1);
  else
    indx = find(Image(:,:,1) == 255 & Image(:,:,2) == 255 & Image(:,:,3) == 255);
  end
  % initialize matrix of white elements
  WhiteElm = zeros(size(Image,1),size(Image,2));
  % set 1 for white color
  WhiteElm(indx) = 1;
  % set the border equal to white for all function
  WhiteElm(1:end,1) = 1;
  WhiteElm(1:end,end) = 1;
  WhiteElm(1,1:end) = 1;
  WhiteElm(end,1:end) = 1;
  % get the col index of total white columns
  allA = all(WhiteElm);
  % remove the white columns and the side top/bottom borders
  Image(:,allA,:) = [];
  Image(1,:,:) = [];
  Image(end,:,:) = [];
  
  ImageFileCropped = Image;
  
  imwrite(ImageFileCropped, [ImagePath,'\', ImageName, '.', CroppedImageExtension]);
  
elseif ImageSize
  
  % crop image manually
  ImageFileCropped = imcrop(Image, ImageSize);
  
else
  
  ImageFileCropped = [];
    
end % Autocrop

end % function