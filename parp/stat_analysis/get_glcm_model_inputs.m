function [feature_set, rcb] = get_glcm_model_inputs(str_pre_or_post_chemo)
% Get model inputs from lesion struct
% [feature_set, rcb] = get_glcm_model_inputs(str_pre_or_post_chemo)
% 
% Unlike in most other functions, str_pre_or_post_chemo can be 'pre',
%  'post', 'both', or 'both_and_diff' (which includes both pre and post and
%  their differences)

% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id$

%% Load precomputed glcm struct(s)
glcm_struct_filename_pre = fullfile(qilsoftwareroot, 'parp', 'lesion_parameters_pre.mat');
glcm_struct_filename_post = fullfile(qilsoftwareroot, 'parp', 'lesion_parameters_post.mat');

load(glcm_struct_filename_pre, 'glcm_struct');
glcm_struct_pre = glcm_struct;
load(glcm_struct_filename_post, 'glcm_struct');
glcm_struct_post = glcm_struct;
clear glcm_struct;

%% Create FeatureSet objects
switch str_pre_or_post_chemo
  case 'pre'
    feature_set = parse_one_glcm_struct(glcm_struct_pre, 'GLCM pre');
  case 'post'
    feature_set = parse_one_glcm_struct(glcm_struct_post, 'GLCM post');
  case {'both', 'both_and_diff'}
    feature_set_pre = parse_one_glcm_struct(glcm_struct_pre, 'GLCM pre');
    feature_set_post = parse_one_glcm_struct(glcm_struct_post, 'GLCM post');
    
    feature_set = [feature_set_pre, feature_set_post];

    if strcmp(str_pre_or_post_chemo, 'both_and_diff')
      feature_set_diff = feature_set_post - feature_set_pre;
      feature_set_diff.FeatureCategoryName = 'GLCM diff';
      feature_set = [feature_set, feature_set_diff];
    end
end

%% Error check
if ~feature_set.bAllFeaturesValid
  error('Some features are not valid');
end

%% Return RCB
if nargout >= 4
  si = get_spreadsheet_info(patient_ids);
  rcb = [si.rcb_value].';
end

function feature_set = parse_one_glcm_struct(glcm_struct, name)
%% Function: Parse a single GLCM struct (either pre or post chemo)

X = nan(length(glcm_struct), 0);
X_names = {};

fn = fieldnames(rmfield(glcm_struct, {'patient_id', 'rcb_val'}));
for kk = 1:length(fn)
  if ischar(glcm_struct(1).(fn{kk}))
    if length(fn{kk}) >=6 && strcmp(fn{kk}(1:6), 'birads')
      continue; % Don't bother with the BI-RADS stuff for now
    end
    
    % This variable is text, e.g., 'SPICULATED' or 'IRREGULAR'
    % First, turn the text labels into indices, e.g., 1=SPICULATED,
    % 2=IRREGULAR, etc.
    [B, B_names] = grp2idx({glcm_struct.(fn{kk})});
    B_names = cellfun(@(x) [fn{kk} '_' x], strrep(lower(B_names), ' ', '_'), 'uniformoutput', false);

    % Then make dummy variables which are vectors which are 1 if the
    % lesion is in that category, and 0 otherwise (also known as "indicator
    % variables")
    d = dummyvar(B);
    
    % Since we only need n-1 indicator variables for n categories, get rid
    % of the last one
    % d = d(:, 1:end-1);
    % B_names = B_names(1:end-1)
    
    X = [X d];
    X_names = [X_names cellfun(@(str) [fn{kk} '_' str], B_names, 'uniformoutput', false).'];
  else
    X = [X [glcm_struct.(fn{kk})].'];
    X_names = [X_names fn{kk}];
  end
end

patient_ids = [glcm_struct.patient_id].';

feature_set = FeatureSet(X, patient_ids, X_names, [], name);
