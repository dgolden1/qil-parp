function [feature_set, glcm] = GetFeatureGLCMFull(obj, varargin)
% Get GLCM properties averaged across the 8-neighborhood
% Gets properties from the MEX file haralick(), which includes most of the properties
% from the original Haralick 1973 paper
% 
% If grayco_offsets is not given, it defaults to the 8-neighborhood

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id: GetFeatureGLCMFull.m 247 2013-04-19 21:57:06Z dgolden $

%% Parse input arguments
p = inputParser;
p.addParamValue('grayco_offsets', [0 1; -1 1; -1 0; -1 -1]);
p.addParamValue('quantiles', [0.01 0.99]);
p.addParamValue('numlevels', 8);
p.parse(varargin{:});

%% Get properties for each angle
% Account for empty image or missing ROI
if isempty(obj.Image)
  fn = {'Contrast', 'Correlation', 'Energy', 'Homogeneity'};
  for kk = 1:length(fn)
    glcm_props_all.(fn{kk}) = nan(1, 4);
  end
else
  img = GetImageNanOutsideROI(obj);

  s = warning('off', 'Images:graycomatrix:scaledImageContainsNan'); % We know the image has NaNs
  glcm = graycomatrix(img, 'Offset', p.Results.grayco_offsets, 'graylimits', quantile(img(:), p.Results.quantiles), 'NumLevels', p.Results.numlevels, 'symmetric', true);
  warning(s.state, 'Images:graycomatrix:scaledImageContainsNan');

  for kk = 1:size(glcm, 3)
    [glcm_props_all(kk,:), prop_names] = haralick(glcm(:,:,kk));
  end
end

%% Average across angles
glcm_props = mean(glcm_props_all);
prop_names = prop_names.';

%% Make feature set output object
if isempty(obj.ImageName)
  feature_category_name = 'glcm_full';
else
  feature_category_name = ['glcm_full_' obj.ImageName];
end

if isempty(obj.ImagePrettyName)
  feature_category_pretty_name = 'GLCM Full';
else
  feature_category_pretty_name = ['GLCM Full ' obj.ImagePrettyName];
end

feature_set = FeatureSet(glcm_props, obj.PatientID, sanitize_struct_fieldname(prop_names), prop_names, feature_category_name, feature_category_pretty_name);
feature_cat = feature_set.FeatureCategoryName;

%% Add average value as a feature
if isempty(obj.MyROI)
  avg = nan;
else
  avg = mean(obj.Image(obj.MyROI.ROIMask));
end

feature_set = [feature_set, FeatureSet(avg, obj.PatientID, {'avg'}, {'Average'}, obj.ImageName, obj.ImagePrettyName)];
feature_set.FeatureCategoryName = feature_cat;

1;
