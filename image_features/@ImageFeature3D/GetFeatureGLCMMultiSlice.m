function feature_set = GetFeatureGLCMMultiSlice(obj, varargin)
% Get GLCM features averaged across multiple slices
% 
% PARAMETERS
% min_size_type: one of 'num_pixels' (default) for the minimum size to be expressed in
%  pixels, or 'percent' for the minimum size to be expressed as a percent of max
% min_size: minimum size, in units of min_size_type (default: 64)
% b_tighten_roi: tighten ROI for lung CT (default: false)
% tightening_thresh: pixel value threshold for ROI tightening (default: -400)
  
% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('min_size_type', 'num_pixels');
p.addParamValue('min_size', 64);
p.addParamValue('min_num_slices', 1);
p.addParamValue('b_tighten_roi', false);
p.addParamValue('tightening_thresh', -400);
p.parse(varargin{:});

%% Setup
feature_category_name = 'glcm_multi_slice';
feature_category_pretty_name = 'GLCM Multi-Slice';

%% Get ImageFeature3D and tighten ROI
if p.Results.b_tighten_roi
  obj = TightenLungCTROI(obj, 'tightening_thresh', p.Results.tightening_thresh);
end

%% Find slice areas
roi_mask_3d = obj.MyROI3D.GetROIMask;
areas = squeeze(cellfun(@(x) sum(x(:)), num2cell(roi_mask_3d, [1 2])));

%% Find subset of slices to include
switch p.Results.min_size_type
  case 'num_pixels'
    idx_slices_to_include = find(areas >= p.Results.min_size);
  case 'percent'
    idx_slices_to_include = find(areas >= p.Results.min_size/100*max(areas));
  otherwise
    error('Invalid value for min_size_type: %s', p.Results.min_size_type);
end

%% If there aren't enough slices, set feature values to NaN and return
if length(idx_slices_to_include) < p.Results.min_num_slices
  % A complicated step to construct the feature names
  feature_names_prefixes = {'avg', 'glcm_contrast', 'glcm_corr', 'glcm_energy', 'glcm_homog'};
  feature_names_suffixes = {'slice_mean', 'slice_std'};
  feature_pretty_names_prefixes = {'Average', 'GLCM Contrast', 'GLCM Correlation', 'GLCM Energy', 'GLCM Homogeneity'};
  feature_pretty_names_suffixes = {'Slice Mean', 'Slice St Dev'};
  feature_names = cellfun(@(x) cellfun(@(y) [x '_' y], feature_names_suffixes, 'uniformoutput', false), feature_names_prefixes, 'uniformoutput', false);
  feature_names = [feature_names{:}];
  feature_pretty_names = cellfun(@(x) cellfun(@(y) [x ' ' y], feature_pretty_names_suffixes, 'uniformoutput', false), feature_pretty_names_prefixes, 'uniformoutput', false);
  feature_pretty_names = [feature_pretty_names{:}];
  
  feature_set = FeatureSet(nan(1, length(feature_names)), {obj.PatientID}, feature_names, feature_pretty_names);
  feature_set.FeatureCategoryName = feature_category_name;
  feature_set.FeatureCategoryPrettyName = feature_category_pretty_name;
  return;
end

%% Determine GLCM features for each slice
fs_combined = FeatureSet.empty;
for kk = 1:length(idx_slices_to_include)
  this_z_mm = obj.MyROI3D.ImageZmm(idx_slices_to_include(kk));
  [this_fs, glcm, selected_image_feature] = GetFeatureGLCMRepSlice(obj, 'b_tighten_roi', false, 'z_spatial', this_z_mm);
  this_fs.PatientIDs = {sprintf('%s %0.2f %s', obj.PatientID, this_z_mm, obj.SpatialCoordUnits)};
  fs_combined = [fs_combined; this_fs];
end

%% Get average and standard deviation of features
if length(idx_slices_to_include) > 1
  [feature_vector_mean, feature_vector_var] = centroid(fs_combined.FeatureVector, areas(idx_slices_to_include));
else
  feature_vector_mean = fs_combined.FeatureVector;
  feature_vector_var = zeros(size(fs_combined.FeatureVector));
end

feature_set_mean = FeatureSet(feature_vector_mean, {obj.PatientID}, ...
  cellfun(@(x) sprintf('%s_slice_mean', x), fs_combined.FeatureNames, 'uniformoutput', false), ...
  cellfun(@(x) sprintf('%s Slice Mean', x), fs_combined.FeaturePrettyNames, 'uniformoutput', false), '', '');

feature_set_std = FeatureSet(sqrt(feature_vector_var), {obj.PatientID}, ...
  cellfun(@(x) sprintf('%s_slice_std', x), fs_combined.FeatureNames, 'uniformoutput', false), ...
  cellfun(@(x) sprintf('%s Slice St Dev', x), fs_combined.FeaturePrettyNames, 'uniformoutput', false), '', '');

feature_set = [feature_set_mean, feature_set_std];
feature_set.FeatureCategoryName = feature_category_name;
feature_set.FeatureCategoryPrettyName = feature_category_pretty_name;



1;
