function feature_set = GetFeatureForAllIFs(obj, feature_fun, varargin)
% Get a given ImageFeature feature for all ImageFeature objects
% feature_fun is a function handle to an ImageFeature method
% 
% varargin is passed as arguments to the ImageFeature method

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

defined_image_features = GetDefinedIFs(obj);
if length(defined_image_features) ~= 7
  error('Must have all image features defined');
end

% Don't include post-contrast image (for consistency with past results)
defined_image_features = defined_image_features(~ismember(defined_image_features, 'IFPostContrast'));

feature_set = FeatureSet.empty;
for kk = 1:length(defined_image_features)
  this_image_feature = obj.(defined_image_features{kk});
  feature_set = [feature_set, feature_fun(this_image_feature, varargin{:})];
end

% If we requested GLCM features, tack on a feature relating to lesion area
feature_cat = feature_set.FeatureCategoryName;
if isequal(feature_fun, @GetFeatureGLCM)
  lesion_area = sum(obj.MyROI.ROIMask(:))*obj.PixelSpacing;
  feature_set = [feature_set, FeatureSet(lesion_area, obj.PatientID, 'lesion_area', 'Lesion Area')];
  
  feature_set.FeatureCategoryName = feature_cat;
end
