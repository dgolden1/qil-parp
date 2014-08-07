function feature_set = get_jiajings_pipeline_features(varargin)
% Parse output from Jiajing's pipeline
% [X, X_names, patient_id] = get_jiajings_pipeline_features(xls_filename)

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Input arguments
p = inputParser;
p.addParamValue('xls_filename', '/Users/dgolden/Documents/qil/case_studies/parp/dicom_aim_for_jiajing_pipeline/all_features_post_img.xlsx');
p.addParamValue('img_type', '');
p.addParamValue('b_remove_nan_features', true);
p.parse(varargin{:});
xls_filename = p.Results.xls_filename;
img_type = p.Results.img_type;
b_remove_nan_features = p.Results.b_remove_nan_features;

%% Get XLS filenames
if ~isempty(img_type)
  if strcmp(img_type, 'all')
    img_types = {'post_img', 'ktrans', 'kep', 've', 'wash_in', 'wash_out', 'auc'};
    for kk = 1:length(img_types)
      xls_filenames{kk} = get_xls_filename_from_img_type(img_types{kk});
    end
  else
    xls_filename = get_xls_filename_from_img_type(img_type);
    xls_filenames = {xls_filename};
    img_types = {img_type};
  end
elseif ~exist(xls_filename, 'file')
  error('%s not found', xls_filename);
else
  img_types = {''};
  xls_filenames = {xls_filename};
end

for kk = 1:length(xls_filenames)
  [X_vec{kk} X_names{kk} this_patient_id] = get_features_from_one_file(xls_filenames{kk});
  if exist('patient_id', 'var')
    assert(isequal(this_patient_id, patient_id));
  else
    patient_id = this_patient_id;
  end
  
  X_names{kk} = cellfun(@(x) [img_types{kk} ' ' x], X_names{kk}, 'UniformOutput', false);
end

X = cell2mat(X_vec);
X_names = [X_names{:}];

%% Remove NaN features
if b_remove_nan_features
  idx_valid = all(isfinite(X), 1);
  X = X(:, idx_valid);
  X_names = X_names(idx_valid);
end

%% Make FeatureSet object
feature_set = FeatureSet(X, patient_id, X_names, [], 'JJ');

function [X, X_names, patient_id] = get_features_from_one_file(xls_filename)
%% Function: get features from a single file

%% Load XLS data
% Load from saved .mat file, if the .mat file is newer than the XLS file
mat_filename = strrep(xls_filename, '.xlsx', '.mat');
if exist(mat_filename, 'file')
  d_xls = dir(xls_filename);
  d_mat = dir(mat_filename);
  if d_mat.datenum > d_xls.datenum
    load(mat_filename, 'X', 'X_names', 'patient_id');
    return;
  end
end

% Otherwise, read the XLS file
[num txt raw] = xlsread(xls_filename);

% Make sure there are three header columns
if size(raw, 2) == size(num, 2) + 4
  % The last column is blank
  raw = raw(:,1:end-1);
  txt = txt(:,1:end-1); 
end
assert(size(num, 2) == size(raw, 2) - 3);

%% Get patient IDs
patient_names = txt(2:end, 2);
patient_id = cellfun(@(x) str2double(x(2:4)), patient_names);

%% Get feature names
X_names = txt(1,4:end);

%% Get feature values
X = num;

%% Sort by patient id
[patient_id, sort_idx] = sort(patient_id);
X = X(sort_idx, :);

%% Save for later
save(mat_filename, 'X', 'X_names', 'patient_id');

function xls_filename = get_xls_filename_from_img_type(img_type)
xls_dir = '/Users/dgolden/Documents/qil/case_studies/parp/dicom_aim_for_jiajing_pipeline';

d = dir(fullfile(xls_dir, '*.xlsx'));
idx = ~cellfun(@isempty, strfind({d.name}, img_type)) & cellfun(@(x) x(1) ~= '~', {d.name});
if sum(idx) == 0
  error('No xlsx files found in %s of type %s', xls_dir, img_type);
elseif sum(idx) > 1
  error('Multiple xlsx files found in %s of type %s', xls_dir, img_type);
end
xls_filename = fullfile(xls_dir, d(idx).name);
