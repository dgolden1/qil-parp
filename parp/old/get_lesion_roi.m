function [roi_mask, roi_poly] = get_lesion_roi(slices, x_mm, y_mm, z_mm, t, info, patient_id, str_pre_or_post_chemo)
% Manually determine a lesion ROI using a polygon

% INPUTS
% slices: an NxMxR matrix of NxM slices of DCE-MRI values, once for each
%  of R time points
% x_mm, y_mm and z_mm: the DICOM coordinates for each slice (mm)
% t: the time of each slices in sec
% info: the DICOM header for each slices
% type: either 'empirical' (default) to color lightness by wash-in slope
% and color by wash-out slope or 'pk' to create a cell array of three maps
% for ktrans, kep and ve, respectively
%
% OUTPUTS
% roi_mask: mask of the same size as slices which is true for pixels within
%  the ROI
% roi_poly: the constituent polynomial vertices of the ROI; x and y are the
%  IMAGE x and y coordinates, not the DICOM x and y coordinates (since the
%  image may not be in the DICOM x-y plane)

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
close all

%% Get lesion center
[x_coord_mm, y_coord_mm, x_label, y_label, slice_location_mm, slice_label] = get_img_coords(x_mm, y_mm, z_mm);

if exist('patient_id', 'var') && ~isempty(patient_id)
  lesion_center_xy = get_lesion_center_from_spreadsheet(patient_id, str_pre_or_post_chemo);

  % Mask out a region within 30 pixels of the lesion center to determine
  % color limits
  contrast_mask = false(size(slices(:,:,1)));
  [img_X, img_Y] = meshgrid(x_coord_mm, y_coord_mm);
  contrast_mask(sqrt((img_X - lesion_center_xy(1)).^2 + (img_Y - lesion_center_xy(2)).^2) < 30) = true;
else
  contrast_mask = true(size(slices(:,:,1)));
end


%% Make kinetic map
t_map_start = now;

plot_empirical_kinetic_map(slices, x_mm, y_mm, z_mm, t, info, 'param_type', 'empirical', 'contrast_mask', contrast_mask);
fprintf('Plotted kinetic map in %s\n', time_elapsed(t_map_start, now));
title(sprintf('Emperical kinetic map  patient %d  %s=%0.1f mm', patient_id, slice_label, slice_location_mm));

%% Show lesion center
if exist('patient_id', 'var') && ~isempty(patient_id)
  hold on;
  h_marker = plot(lesion_center_xy(1), lesion_center_xy(2), 'o', 'markersize', 14, 'markeredgecolor', [1 1 1]); % was 'markerfacecolor', [1 0 1]
end

%% Get ROI
uiwait(helpdlg('Select the region ROI'));

h_ax = findobj(gcf, 'tag', 'im_mapped');

% Select ROI
axes(h_ax);
hold on;
roi_poly.img_x_mm = [];
roi_poly.img_y_mm = [];
h_roi = [];
[this_img_x_mm, this_img_y_mm] = ginput(1);
no_add = false;
while ~isempty(this_img_x_mm)
  if ~no_add
    roi_poly.img_x_mm(end+1) = this_img_x_mm;
    roi_poly.img_y_mm(end+1, 1) = this_img_y_mm;
  end
  
  % Plot ROI on original image
  delete(h_roi);
  if ~isempty(roi_poly.img_x_mm)
    h_roi = plot(roi_poly.img_x_mm([1:end 1]), roi_poly.img_y_mm([1:end 1]), 'wo-');
  end

  [this_img_x_mm, this_img_y_mm, button] = ginput(1);
  no_add = false;
  
  if ~isempty(button) && (button == 8 || button == 27 || button == 127) % User pressed escape, backspace or delete (only tested on Windows PC)
    % Quit if we deleted all the points and delete is pressed again
    if isempty(roi_poly.img_x_mm)
      break;
    end
    
    roi_poly.img_x_mm(end) = [];
    roi_poly.img_y_mm(end) = [];
    no_add = true;
  end
end

% User didn't make an ROI
if length(roi_poly.img_x_mm) <= 2
  response = questdlg('Is the lesion visible?');
  switch response
    case 'Yes'
      error('ROI Polygon must have more than 2 vertices');
    case 'No'
      roi_mask = false(size(slices(:,:,1)));
      roi_poly = struct('img_x_mm', [], 'img_y_mm', []);
      return;
    case 'Cancel'
      error('ROI specification aborted');
  end
end

%% Mask ROI
% Get ROI in pixels (not necessarily rounded); necessary for poly2mask function
[x_roi_px, y_roi_px] = roi_mm_to_px(x_coord_mm, y_coord_mm, roi_poly.img_x_mm, roi_poly.img_y_mm);
roi_mask = poly2mask(x_roi_px, y_roi_px, size(slices, 1), size(slices, 2));

1;

% % Plot only pixels that are part of ROI (to make sure it worked)
% figure;
% image(y_mm, z_mm, rgb_img.*repmat(roi_mask, [1 1 3]));
% axis equal tight xy
% xlabel('Y (mm)');
% ylabel('Z (mm)');
% title('Image colored by empirical dye dilution (lesion only)');
