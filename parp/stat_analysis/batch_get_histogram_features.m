function feature_set = batch_get_histogram_features(str_pre_or_post_chemo)
% Get histogram features for PARP patients

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

%% Setup
addpath(fullfile(qilsoftwareroot, 'parp'));
addpath(fullfile(qilsoftwareroot, 'image_features'));
patient_ids = get_processed_patient_list(str_pre_or_post_chemo);

common_resolution = 1.5; % mm/pixel

%% Save last result persistently to save time
persistent hist_features last_str_pre_or_post_chemo
if isequal(last_str_pre_or_post_chemo, str_pre_or_post_chemo) && ~isempty(hist_features)
  [X, X_names, patient_id] = struct_to_feature_vector(hist_features);
  return;
end

%% Loop over patients
feature_set = repmat(FeatureSet, 0, 0);

warning('off', 'get_contrast_info:unknownInfo');
idx_valid = true(size(patient_ids));
for kk = 1:length(patient_ids)
  t_start = now;
  
  info = [];
  [slice_filename, roi_filename, pk_filename] = get_slice_filename(patient_ids(kk), str_pre_or_post_chemo);
  if isempty(roi_filename) || isempty(pk_filename)
    idx_valid(kk) = false;
    continue;
  end

  load(slice_filename);
  load(roi_filename);
  load(pk_filename);
  
  [x_coord_mm, y_coord_mm] = get_img_coords(x_mm, y_mm, z_mm);
  
  % Resize slices to common resolution
  mm_per_pixel = abs(median(diff(x_coord_mm)));
  scale_factor = mm_per_pixel/common_resolution;
  [slices_resized, roi_mask_resized, x_coord_mm_resized, y_coord_mm_resized] = resize_img_and_roi(slices, roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor);
  
  % Get empirical maps for resized slices
  [~, ~, slices_resized_masked] = mask_2d_nd(slices_resized, roi_mask_resized);
  [wash_in_slope, wash_out_slope, area_under_curve, post_contrast_img] = get_empirical_params(slices_resized_masked, info, t);
  
  % Resize PK maps
  % Each PK parameter needs its own mask, because b_constrain_output is true, which
  % means that the output masks may have weird shapes
  [ktrans_resized, roi_masks_resized.ktrans] = resize_img_and_roi(ktrans, roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor, true);
  [kep_resized, roi_masks_resized.kep] = resize_img_and_roi(kep, roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor, true);
  [ve_resized, roi_masks_resized.ve] = resize_img_and_roi(ve, roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor, true);
  
  [x_roi_px, y_roi_px] = roi_mm_to_px(x_coord_mm_resized, y_coord_mm_resized, roi_poly.img_x_mm, roi_poly.img_y_mm);
  
  % Make a struct with all the (resized) maps
  map.ktrans = ktrans_resized;
  map.kep = kep_resized;
  map.ve = ve_resized;
  map.wash_in = wash_in_slope;
  map.wash_out = wash_out_slope;
  map.auc = area_under_curve;
  map.post_contrast_img = post_contrast_img;
  
  fn = fieldnames(map);
  this_patient_feature_set = repmat(FeatureSet, 0, 0);
  for jj = 1:length(fn)
    if ismember(fn{jj}, {'ktrans', 'kep', 've'})
      this_mask = roi_masks_resized.(fn{jj});
    else
      this_mask = roi_mask_resized;
    end
    
    map_masked = nan(size(slices_resized(:,:,1)));
    map_masked(this_mask) = map.(fn{jj});
    
    this_image_name = sprintf('%s chemo %s', str_pre_or_post_chemo, fn{jj});
    IF = ImageFeature(map_masked, 'ImageName', this_image_name, 'ID', patient_ids(kk), ...
      'ROIPolyX', x_roi_px, 'ROIPolyY', y_roi_px, 'SpatialXCoords', x_coord_mm_resized, ...
      'SpatialYCoords', y_coord_mm_resized, 'SpatialCoordUnits', 'mm');
    
    % Combine different feature sets for this patient
    this_feature_set = GetFeatureHist(IF);
    this_patient_feature_set = [this_patient_feature_set, GetFeatureHist(IF)];
  end
  
  % Combine different patients
  feature_set = [feature_set; this_patient_feature_set];
  
  fprintf('Processed patient %03d (%d of %d) in %s\n', patient_ids(kk), kk, length(patient_ids), time_elapsed(t_start, now));
end
warning('on', 'get_contrast_info:unknownInfo');

1;
