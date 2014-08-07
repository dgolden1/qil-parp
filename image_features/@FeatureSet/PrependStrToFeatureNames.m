function obj = PrependStrToFeatureNames(obj, str, pretty_str)
% Prepend a string to each of the feature names
% PrependStrToFeatureNames(obj, str, pretty_str)
% 
% This particularly helps to disambiguate features when horizontally concatenating two
% feature sets together

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

if exist('str', 'var') && ~isempty(str)
  obj.FeatureNames = cellfun(@(x) sanitize_struct_fieldname([str '_' x]), obj.FeatureNames, 'UniformOutput', false);
end

if exist('pretty_str', 'var') && ~isempty(pretty_str)
  obj.FeaturePrettyNames = cellfun(@(x) [pretty_str ' ' x], obj.FeaturePrettyNames, 'UniformOutput', false);
end
