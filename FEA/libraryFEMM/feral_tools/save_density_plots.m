%% Script for saving the density plots

%% Prepare folder
if isOctave
  pkg load image
end

% Append the ID to the folder name if defined
if ~isfield(SD, 'TempID')
  SD.DensityPlotFolder = [SD.DensityPlotFolderPath, '/', SD.DensityPlotFolderName];
else
  SD.DensityPlotFolder = [SD.DensityPlotFolderPath, '/', SD.DensityPlotFolderName, '_', num2str(SD.TempID)];
end

% Create the folder
if ~exist(SD.DensityPlotFolder, 'dir')
  mkdir(SD.DensityPlotFolder);
end

%% Customize and save shaded plots (B and J)
for ImgIndx = 1:length(SD.DensityPlotType)
  
  % Hide flux lines if required
  if SD.HideContourPlot
     mo_hidecontourplot()
  end
  
  % Show density plot (B or J)
  mo_showdensityplot( SD.DensityPlotLegend(ImgIndx), ... % add legend or not
                      SD.DensityPlotGray(ImgIndx), ... color or gray
                      SD.DensityPlotMax(ImgIndx), ... Bmax, Jmax
                      SD.DensityPlotMin(ImgIndx), ... Bmin, Jmin
                      SD.DensityPlotType{ImgIndx}); ... B or J 
  
  % Set post-processing window zoom
  if ~isempty(SD.DensityPlotZoom)
    mo_zoom(SD.DensityPlotZoom(1), SD.DensityPlotZoom(2), SD.DensityPlotZoom(3), SD.DensityPlotZoom(4));
  else
    mo_zoomnatural
  end
  
  % Create the Image name with some simulation info
  SD.ImageName = [SD.DensityPlotFolder, '/', SD.DensityPlotType{ImgIndx}, ...
                                      '_skew_', number2string(skew,'o'), '_deg', ...
                                       '_Ipk_', number2string(Ipeak,'o'), '_A', ...
                                      '_aie_', number2string(alphaie,'o'), '_deg', ...     
                                      '_thme_', number2string(thetame,'o'), '_deg_', ...                                 
                                      datestr(clock,30)];
                                    
  % Create a copy of the .ans file for the user 
  copyfile([SD.TempFolder, '/', SD.TempFileName,'.ans'], [SD.ImageName,'.ans'], 'f');
  
  % Save the picture in bitmap extension
  mo_savebitmap([SD.ImageName, '.bmp']);
  
  % Convert picture extension and get data (pixels)
  ImageData = convert_image_extension([SD.ImageName, '.bmp'], [SD.ImageName, '.', SD.ImageExtension], 1);
  
  % Crop FEMM image (remove the boundary rules and the empty region)
  ImageDataCropped = crop_femm_image([SD.ImageName, '.', SD.ImageExtension], SD.ImageCrop, SD.ImageSize, SD.ImageExtension);
  
  if SD.ImageTransparency
    remove_image_color([SD.ImageName, '.', SD.ImageExtension], [255 255 255], 0);
  end
  
  SD.ImageNameList{ImgIndx} =  [SD.ImageName];
  
end

for ImgIndx = 1:length(SD.DensityPlotType)

  if SD.SaveAnsFiles == 0
    delete([SD.ImageNameList{ImgIndx}, '.ans']);
  end

end
