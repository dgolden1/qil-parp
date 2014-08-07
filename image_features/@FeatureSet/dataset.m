function data_set = dataset(obj)
% Convert to dataset class

% By Daniel Golden (dgolden1 at gmail dot com) November 2013
% $Id$

data_set = dataset({obj.FeatureVector, obj.FeatureNames{:}});
data_set.Properties.VarDescription = obj.FeaturePrettyNames;

if iscellstr(obj.PatientIDs)
  data_set.Properties.ObsNames = obj.PatientIDs;
else
  data_set.Properties.ObsNames = cellfun(@num2str, num2cell(obj.PatientIDs), 'uniformoutput', false);
end

data_set.Properties.Description = obj.FeatureCategoryPrettyName;
1;
