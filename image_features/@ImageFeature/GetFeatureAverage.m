function feature_set = GetFeatureAverage(obj)
% Get lesion-averaged kinetic map values and lesion area

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id: GetFeatureAverage.m 185 2013-02-13 01:42:05Z dgolden $

if isempty(obj.MyROI)
  avg = nan;
else
  avg = mean(obj.Image(obj.MyROI.ROIMask));
end

feature_set = FeatureSet(avg, obj.PatientID, [obj.ImageName '_avg'], [obj.ImagePrettyName ' Average']);

1;
