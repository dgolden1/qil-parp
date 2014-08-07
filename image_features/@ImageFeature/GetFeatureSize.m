function feature_set = GetFeatureSize(obj)
% Get the size of the ROI as a feature

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id: GetFeatureSize.m 133 2012-12-18 23:37:41Z dgolden $

if isempty(obj.MyROI)
  size = nan;
else
  size = sum(obj.MyROI.ROIMask(:))*obj.SpatialRes^2;
end

feature_set = FeatureSet(size, obj.PatientID, 'area', 'Lesion Area', obj.ImageName, obj.ImagePrettyName);
