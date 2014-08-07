function obj_sum = horzcat(varargin)
% Combine two feature sets together, taking the union of features and
% intersection of patient IDs

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

%% Parse input arguments

% Allow concatenation with an empty FeatureSet be removing empty FeatureSet
% objects from the input argument list
varargin = varargin(~cellfun(@isempty, varargin));

if isempty(varargin)
  % Contatenation of two empty FeatureSet objects
  obj_sum = FeatureSet.empty;
  return;
elseif length(varargin) == 1
  % base case
  obj_sum = varargin{1};
  return;
elseif length(varargin) > 2
  % Recurse
  obj_sum_12 = horzcat(varargin{1}, varargin{2});
  obj_sum = horzcat(obj_sum_12, varargin{3:end});
  return;
else
  % At this point, there should be two input arguments
  narginchk(2, 2);
  
  obj1 = varargin{1};
  obj2 = varargin{2};
end

%% Error checking
if ~isempty(obj1.FeatureCategoryName) && strcmp(obj1.FeatureCategoryName, obj2.FeatureCategoryName)
  error('obj1 and obj2 FeatureCategoryName properties are equal (%s)', obj1.FeatureCategoryName);
end

PatientIDs_intersect = intersect(obj1.PatientIDs, obj2.PatientIDs);
if isempty(PatientIDs_intersect)
  error('No patient IDs in common between obj1 and obj2');
end

%% Combine feature vectors and feature names
FeatureVector1 = obj1.FeatureVector(ismember(obj1.PatientIDs, PatientIDs_intersect), :);
FeatureVector2 = obj2.FeatureVector(ismember(obj2.PatientIDs, PatientIDs_intersect), :);
FeatureVector_combined = [FeatureVector1 FeatureVector2];

FeatureNames_combined = [obj1.FeatureNames obj2.FeatureNames];
FeaturePrettyNames_combined = [obj1.FeaturePrettyNames obj2.FeaturePrettyNames];

%% Combine feature category names
% If both feature sets have their category name defined, concatenate them with a
% plus sign; otherwise, straight up concatenate them, which will just choose
% whichever one isn't empty
if ~isempty(obj1.FeatureCategoryName) && ~isempty(obj2.FeatureCategoryName)
  FeatureCategoryName_combined = [obj1.FeatureCategoryName '_and_' obj2.FeatureCategoryName];
  FeatureCategoryPrettyName_combined = [obj1.FeatureCategoryPrettyName ' and ' obj2.FeatureCategoryPrettyName];
else
  FeatureCategoryName_combined = [obj1.FeatureCategoryName obj2.FeatureCategoryName];
  FeatureCategoryPrettyName_combined = [obj1.FeatureCategoryPrettyName obj2.FeatureCategoryPrettyName];
end

%% Make a new feature set
obj_sum = FeatureSet(FeatureVector_combined, PatientIDs_intersect, FeatureNames_combined, FeaturePrettyNames_combined, '');
obj_sum.FeatureCategoryName = FeatureCategoryName_combined; % Set category name after creating the object so it doesn't get appended to feature names
obj_sum.FeatureCategoryPrettyName = FeatureCategoryPrettyName_combined; % Set category name after creating the object so it doesn't get appended to feature names

obj_sum.Comment = make_comma_separated_list({obj1.Comment, obj2.Comment});

%% Assign response
if isempty(obj2.ResponseName) && isempty(obj2.Response)
  obj_sum.ResponseName = obj1.ResponseName;
  obj_sum.Response = obj1.Response;
elseif isempty(obj1.ResponseName) && isempty(obj1.Response)
  obj_sum.ResponseName = obj2.ResponseName;
  obj_sum.Response = obj2.Response;
else
  if isequal(obj1.ResponseName, obj2.ResponseName) && isequal(obj1.Response, obj2.Response)
    obj_sum.ResponseName = obj1.ResponseName;
    obj_sum.Response = obj1.Response;
  else
    error('Attempted horizontal concatenation of features with disparate responses');
  end
end
