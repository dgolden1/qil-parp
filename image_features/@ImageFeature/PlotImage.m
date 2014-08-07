function PlotImage(obj, varargin)
% Plot the image, possibly with the ROI
% PlotImage(obj, varargin)
% 
% PARAMETERS
% colormap (default: 'jet')
% b_ROI (default: true)
% b_cax_from_roi: true (default) to select the color axis based on value quantiles from
%  within the ROI instead of the whole image
% b_spatial_coords: True to plot in DICOM coordinates and show axis (default: false)
% cax_quantile (default: [0.01 0.99])
% slice_idx (default: 1)
% h_ax (default: [])
% 
% Unmatched parameters are passed to ROI.PlotROI

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id: PlotImage.m 343 2013-07-13 00:04:54Z dgolden $

%% Parse input arguments
p = inputParser;
p.addParamValue('colormap', 'jet');
p.addParamValue('b_ROI', true);
p.addParamValue('b_cax_from_roi', true);
p.addParamValue('b_spatial_coords', false);
p.addParamValue('cax_quantile', [0.01 0.99]);
p.addParamValue('slice_idx', 1); % For a 3D Image, index of slice
p.addParamValue('h_ax', []); % Axis on which to plot

[args_in, args_out] = arg_subset(varargin, p.Parameters);
p.parse(args_in{:});

%% Set up axes
if isempty(p.Results.h_ax)
  figure;
  h_ax = axes;
else
  h_ax = p.Results.h_ax;
end
saxes(h_ax);

%% Define X and Y coordinates
if p.Results.b_spatial_coords
  x = obj.SpatialXCoords;
  y = obj.SpatialYCoords;
else
  x = 1:size(obj.Image, 2);
  y = 1:size(obj.Image, 1);
end

%% Plot image
h = imagesc(x, y, obj.Image(:,:,p.Results.slice_idx));
set(h, 'tag', 'image_feature_image');
colormap(p.Results.colormap);

% A combined ROI mask in the case of multiple ROIs
roi_mask_combined = false(size(obj.Image));
for kk = 1:length(obj.MyROI)
  roi_mask_combined = roi_mask_combined | obj.MyROI(kk).ROIMask;
end

if p.Results.b_cax_from_roi && sum(roi_mask_combined(:)) > 0 && any(isfinite(obj.Image(roi_mask_combined)))
  caxis(quantile(obj.Image(roi_mask_combined), p.Results.cax_quantile));
else
  caxis(quantile(obj.Image(:), p.Results.cax_quantile));
end

axis equal tight;
if p.Results.b_spatial_coords
  xlabel('mm');
  ylabel('mm');
else
  axis off;
end

%% Plot ROI
if p.Results.b_ROI && ~isempty(obj.MyROI)
  if strcmp(p.Results.colormap, 'jet')
    roi_color = 'w';
  else
    roi_color = 'r';
  end
  
  roi = obj.MyROI;
  
  % Plot (possibly multiple) ROIs
  for kk = 1:length(roi)
    if p.Results.b_spatial_coords
      roi(kk).bPlotInmm = true;
    end

    hold on;
    PlotROI(roi(kk), 'roi_color', roi_color, args_out{:});
  end
  
  if length(roi) > 1
    roi_cell = num2cell(roi);
    roi_conv_hull = ROI.CombineROIs(roi_cell{:});
    PlotZoomToROI(roi_conv_hull);
  end
  
end

%% Massage image
title(sprintf('Patient %s %s', patient_id_tostr(obj.PatientID), obj.ImagePrettyName));

increase_font;
