function pic = convert_image_extension(Original, Converted, DeleteOriginal)

% check optinal input
% by default the original file is deleted
if nargin < 3
  DeleteOriginal = 1;
end

% get image matrix
pic = imread(Original);
% save converted image
imwrite(pic, Converted);

% delete original file
if DeleteOriginal
  delete(Original)
end

end % function