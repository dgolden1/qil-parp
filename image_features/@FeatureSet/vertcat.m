function obj_sum = vertcat(varargin)
% Combine two feature sets together, taking the union of patient IDs
% Feature names and feature category names must be equal and patient
% IDs must be unique for both objects

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

% Allow concatenation with an empty FeatureSet be removing empty FeatureSet
% objects from the input argument list
varargin = varargin(~cellfun(@isempty, varargin));

if length(varargin) == 1
  % base case
  obj_sum = varargin{1};
  return;
elseif length(varargin) > 2
  % Recurse
  obj_sum_12 = vertcat(varargin{1}, varargin{2});
  obj_sum = vertcat(obj_sum_12, varargin{3:end});
  return;
else
  % At this point, there should be two input arguments
  narginchk(2, 2);
  
  obj1 = varargin{1};
  obj2 = varargin{2};
end


if ~isequal(obj1.FeatureNames, obj2.FeatureNames)
  error('FeatureNames properties are not equal');
end
if ~isequal(obj1.FeaturePrettyNames, obj2.FeaturePrettyNames)
  error('FeaturePrettyNames properties are not equal');
end
if ~strcmp(obj1.FeatureCategoryName, obj2.FeatureCategoryName)
  error('FeatureCategoryName properties are not equal');
end
if ~isempty(intersect(obj1.PatientIDs, obj2.PatientIDs))
  error('PatientIDs properties must be unique for both objects');
end

[PatientIDs_combined, sort_idx] = sort([obj1.PatientIDs; obj2.PatientIDs]);
FeatureVector_combined = [obj1.FeatureVector; obj2.FeatureVector];
FeatureVector_combined = FeatureVector_combined(sort_idx, :);

obj_sum = FeatureSet(FeatureVector_combined, PatientIDs_combined, obj1.FeatureNames, ...
  obj1.FeaturePrettyNames, '');

if ~strcmp(obj1.Comment, obj2.Comment)
  warning('FeatureSet comments differ; using comment from first object');
end
obj_sum.Comment = obj1.Comment;

% Set category name after creating the object so it doesn't get appended to feature names
obj_sum.FeatureCategoryName = obj1.FeatureCategoryName;
obj_sum.FeatureCategoryPrettyName = obj1.FeatureCategoryPrettyName;
