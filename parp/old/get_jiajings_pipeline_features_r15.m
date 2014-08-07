function [X, X_names, patient_id] = get_jiajings_pipeline_features_r15(xls_filename)
% Parse output from Jiajing's pipeline
% [X, X_names, patient_id] = get_jiajings_pipeline_features(xls_filename)

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Load XLS data
if ~exist('xls_filename', 'var') || isempty(xls_filename)
  xls_filename = '/Users/dgolden/Documents/qil/case_studies/parp/dicom_aim_for_jiajing_pipeline/all_features_20120810_123405_Breast.xlsx';
end
if ~exist(xls_filename, 'file')
  error('%s not found', xls_filename);
end

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

%% Save for later
save(mat_filename, 'X', 'X_names', 'patient_id');
