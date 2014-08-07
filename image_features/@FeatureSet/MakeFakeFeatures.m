function feature_set = MakeFakeFeatures(num_patients, num_features)
% feature_set = MakeFakeFeatures(num_patients, num_features)
% 
% INPUTS
% num_patients (default: 50)
% num_features (default: 100)

% By Daniel Golden (dgolden1 at stanford dot edu) July 2013
% $Id$

feature_vector = randn(num_patients, num_features);
patient_names = cellfun(@(x) sprintf('Patient %03d', x), num2cell(1:num_patients), 'UniformOutput', false)';
feature_names = cellfun(@(x) sprintf('Feature %04d', x), num2cell(1:num_features), 'UniformOutput', false)';

feature_set = FeatureSet(feature_vector, patient_names, feature_names, feature_names, '', '');
