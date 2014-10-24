function roi_struct = get_roi_from_dicomrt(dicom_rt_filename, roi_names_desired, varargin)
% Extact one or more ROIs from a DICOM-RT file
% roi_struct = get_roi_from_dicomrt(filename, roi_name)
% 
% INPUTS
% filename: DICOM-RT filename
% roi_names_desired: a cell array of specific ROI names to extract (e.g., {'BODY',
% 'GTV'}). A single ROI name in a string is allowed. If no names are given, all names
% will be extracted.
% 
% PARAMETERS
% dicom_db: if the LungDICOMDB object is not included here, this function will load it
% b_first_match: instead of retrieving all of the ROI names in roi_names_desired, just
%  return the first member of roi_names_desired that exists in the list of ROIs. This is
%  useful if you don't know the exact name of the ROI that you want, but you have a
%  candidate list of names.
% b_list_rois: only list the ROIs; don't return anything
% 
% OUTPUTS
% roi_struct: a struct with the following fields
%  roi3d: an ROI3D object
%  name: name of the ROI from the DICOM-RT file
% 
% Designed based on a certain set of DICOM-RT files; may not work on all files

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('dicom_db', []);
p.addParamValue('b_first_match', false);
p.addParamValue('b_list_rois', false);
p.parse(varargin{:});

%% Setup
if ~exist('roi_names_desired', 'var') || isempty(roi_names_desired)
  roi_names_desired = {};
elseif ischar(roi_names_desired)
  roi_names_desired = {roi_names_desired};
end

if isempty(p.Results.dicom_db) && exist('LungDICOMDB', 'class')
  dicom_db = LoadDB(LungDICOMDB);
elseif isempty(p.Results.dicom_db)
  error('Must provide dicom_db parameter');
else
  dicom_db = p.Results.dicom_db;
end

%% Load header
info = dicominfo(dicom_rt_filename);

%% Retrieve ROI names
roi_item_names_all = fieldnames(info.StructureSetROISequence);

for kk = 1:length(roi_item_names_all)
  roi_names_all{kk} = info.StructureSetROISequence.(roi_item_names_all{kk}).ROIName;
end

if p.Results.b_list_rois
  fprintf('ROIs: %s\n', make_comma_separated_list(roi_names_all));
  roi_struct = [];
  return;
end

% DEBUG print GTV-like names
% gtv_idx = ~cellfun(@isempty, regexp(roi_names_all, '[^a-zA-Z]?GTV[^a-zA-Z]?', 'once'));
% fprintf('GTV-Like names: %s\n', make_comma_separated_list(roi_names_all(gtv_idx)));


% Choose a subset of ROI names if desired
if ~isempty(roi_names_desired)
  for kk = 1:length(roi_names_desired)
    if ~ismember(roi_names_desired{kk}, roi_names_all) && ~p.Results.b_first_match
      error('ROI ''%s'' not found', roi_names_desired{kk});
    elseif ismember(roi_names_desired{kk}, roi_names_all) && p.Results.b_first_match
      % We want the first match and we found it; just return this member of
      % roi_names_desired
      roi_names_desired = roi_names_desired{kk};
      break;
    end
  end
  
  idx_to_keep = ismember(roi_names_all, roi_names_desired);
  roi_names = roi_names_all(idx_to_keep);
  roi_item_names = roi_item_names_all(idx_to_keep);
  
  if isempty(roi_names) && ~isempty(roi_names_desired)
    error('No desired ROI names (%s) found in this file''s ROIs (%s)', make_comma_separated_list(roi_names_desired), ...
      make_comma_separated_list(roi_names_all));
  end
end

%% Retrieve referenced DICOM file dimensions
image_sequence = info.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence;
image_sequence_names = fieldnames(image_sequence);

% Loop over DICOM files and collect their slice (Z) locations and X and Y coordinates
img_slice_coord_mm_list = nan(length(image_sequence_names), 1);
for kk = 1:length(image_sequence_names)
  this_uid = image_sequence.(image_sequence_names{kk}).ReferencedSOPInstanceUID;
  this_dicom_image = dicom_db.DICOMList(dicom_db.MapUID(this_uid));
  
  img_slice_coord_mm_list(kk) = this_dicom_image.SliceCoordmm;
  
  if kk == 1
    [img_x_coord_mm, img_y_coord_mm] = GetImageCoordinates(this_dicom_image);
  end
end

img_slice_coord_mm_list = sort(img_slice_coord_mm_list);

%% Retrieve ROIs
idx_roi_valid = true(1, length(roi_names));
for kk = 1:length(roi_names)
  t_start = now;
  
  roi_struct(kk).name = roi_names{kk};
  
  if ~isfield(info.ROIContourSequence.(roi_item_names{kk}), 'ContourSequence')
    % Some ROIs don't actually have coordinates
    idx_roi_valid(kk) = false;
    continue;
  end
  
  this_contour = info.ROIContourSequence.(roi_item_names{kk}).ContourSequence;
  this_roi_item_names = fieldnames(this_contour);
  
  rois_2d = ROI.empty;
  
  rois_2d_zvals = nan(length(this_roi_item_names), 1);
  for jj = 1:length(this_roi_item_names)
    this_contour_data = this_contour.(this_roi_item_names{jj}).ContourData;
    x_mm = this_contour_data(1:3:end)';
    y_mm = this_contour_data(2:3:end)';
    
    [x_px, y_px] = mm_to_px(img_x_coord_mm, img_y_coord_mm, x_mm, y_mm);
    
    rois_2d(jj) = ROI(x_px, y_px, img_x_coord_mm, img_y_coord_mm);
    
    % z is usually invariant in a given ROI; just assign a scalar to z if it changes by
    % less than 0.01 mm over the ROI
    z_mm = this_contour_data(3:3:end);
    if all(abs(diff(z_mm)) < 1e-2)
      z_px = interp1(img_slice_coord_mm_list, 1:length(img_slice_coord_mm_list), median(z_mm), 'nearest');
      rois_2d_zvals(jj) = z_px;
    else
      error('z changes by %0.2f > 0.01 mm over ROI', max(abs(diff(z_mm))));
    end
    
    this_uid = this_contour.(this_roi_item_names{jj}).ContourImageSequence.Item_1.ReferencedSOPInstanceUID;
    roi_struct(kk).uid{jj} = this_uid;
  end
  
  roi_struct(kk).roi3d = ROI3D(rois_2d, rois_2d_zvals, img_slice_coord_mm_list);
  
  if length(roi_names) > 1
    fprintf('Processed ROI ''%s'' (%d of %d) in %s\n', roi_struct(kk).name, kk, length(roi_names), ...
      time_elapsed(t_start, now));
  end
end

roi_struct(~idx_roi_valid) = [];
