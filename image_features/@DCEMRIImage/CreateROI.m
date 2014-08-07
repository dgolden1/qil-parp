function obj = CreateROI(obj, lesion_center_xy)
% Manually create ROI on image empirical map

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
close all

if isempty(obj.IFWashIn)
  error('Must run GetEmpiricalMaps() before creating ROI');
end

%% Get lesion center
if exist('lesion_center_xy', 'var') && ~isempty(lesion_center_xy)
  % Mask out a region within 30 pixels of the lesion center to determine
  % color limits
  contrast_mask = false(obj.Size2D);
  [img_X, img_Y] = meshgrid(1:obj.Size2D(1), 1:obj.Size2D(2));
  
  contrast_mask(sqrt((img_X - lesion_center_xy(1)).^2 + (img_Y - lesion_center_xy(2)).^2) < 30) = true;
else
  contrast_mask = true(obj.Size2D);
end

%% Make kinetic map
t_map_start = now;

PlotEmpiricalMapHSV(obj, 'contrast_mask', contrast_mask, 'b_zoom', false, 'b_roi', false);
fprintf('Plotted kinetic map in %s\n', time_elapsed(t_map_start, now));
title(sprintf('Emperical kinetic map  patient %03d  %s=%0.1f mm', obj.PatientID, obj.SliceLabel, obj.SliceCoordmm));

%% Show lesion center
if exist('lesion_center_xy', 'var') && ~isempty(lesion_center_xy)
  hold on;
  h_marker = plot(lesion_center_xy(1), lesion_center_xy(2), 'o', 'markersize', 14, 'markeredgecolor', [1 1 1]); % was 'markerfacecolor', [1 0 1]
end

%% Get ROI
uiwait(helpdlg('Select the region ROI'));

h_ax = findobj(gcf, 'tag', 'im_mapped');

% Select ROI
axes(h_ax);
hold on;
roi_x = [];
roi_y = [];
h_roi = [];
[this_img_x_mm, this_img_y_mm] = ginput(1);
no_add = false;
while ~isempty(this_img_x_mm)
  if ~no_add
    roi_x(end+1) = this_img_x_mm;
    roi_y(end+1, 1) = this_img_y_mm;
  end
  
  % Plot ROI on original image
  delete(h_roi);
  if ~isempty(roi_x)
    h_roi = plot(roi_x([1:end 1]), roi_y([1:end 1]), 'wo-');
  end

  [this_img_x_mm, this_img_y_mm, button] = ginput(1);
  no_add = false;
  
  if ~isempty(button) && (button == 8 || button == 27 || button == 127) % User pressed escape, backspace or delete (only tested on Windows PC)
    if isempty(roi_x)
      % If we deleted all the points and delete is pressed again, then quit
      break;
    end
    
    % Otherwise, delete the last point and continue
    roi_x(end) = [];
    roi_y(end) = [];
    no_add = true;
  end
end

% User didn't make an ROI
if length(roi_x) <= 2
  response = questdlg('Is the lesion visible?');
  switch response
    case 'Yes'
      error('ROI Polygon must have more than 2 vertices');
    case 'No'
      roi_x = [];
      roi_y = [];
    case 'Cancel'
      error('ROI specification aborted');
  end
end

%% Set object properties
obj.MyROI = ROI(roi_x, roi_y, obj.XCoordmm, obj.YCoordmm);

1;
