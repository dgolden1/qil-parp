function fs = GetFeatureVolume(obj)
% Get ROI volume as a feature

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

roi_mask_3d = GetROIMask(obj.MyROI3D);

area = sum(roi_mask_3d(:))*obj.SpatialResInPlane^2*obj.SpatialResOutPlane;

fs = FeatureSet(area, obj.PatientID, 'volume', 'Volume', '', '');

% Set category name after creating the object so it doesn't get appended to feature names
fs.FeatureCategoryName = 'misc';
fs.FeatureCategoryPrettyName = 'Misc';
