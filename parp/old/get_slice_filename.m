function [slice_filename, roi_filename, pk_filename] = get_slice_filename(patient_id_or_dir, str_pre_or_post_chemo, b_allow_multiple_slices, b_pre_post_only)
% Get slice, roi and PK filenames from patient directory; if patient has
% more than one slice, looks for a combined slice
% [slice_filename, roi_filename, pk_filename] = get_slice_filename(patient_id_or_dir, str_pre_or_post_chemo, b_allow_multiple_slices, b_pre_post_only)
% 
% INPUTS
% b_allow_multiple_slices: if false (default) returns an error if multiple
%  slices are found and no combined slice is found. Otherwise, returns all
%  slices

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

%% Setup
if ~exist('b_allow_multiple_slices', 'var') || isempty(b_allow_multiple_slices)
  b_allow_multiple_slices = false;
end
if ~exist('b_pre_post_only', 'var') || isempty(b_pre_post_only)
  b_pre_post_only = false;
end

if ~exist('str_pre_or_post_chemo', 'var') || ~ischar(str_pre_or_post_chemo)
  error('Must provide str_pre_or_post_chemo');
end


% Allow patient ID to be entered instead of patient dir
if isnumeric(patient_id_or_dir)
  patient_dir = get_patient_dir_from_id(patient_id_or_dir, str_pre_or_post_chemo);
else
  patient_dir = patient_id_or_dir;
end

if b_pre_post_only
  patient_dir = fullfile(patient_dir, 'pre_post');
  if ~exist(patient_dir, 'dir')
    error('%s does not exist', patient_dir);
  end
end

%% List all slices
slice_file_list = dir(fullfile(patient_dir, '*slice*.mat'));

%% Parse
if isempty(slice_file_list)
  error('getSlice:noSlices', 'No slice files found in %s', patient_dir);
elseif length(slice_file_list) == 1 || (length(slice_file_list) > 1 && b_allow_multiple_slices)
  % If there's only one slice file, return it; if there are multiple files
  % and we're allowing multiple slices, return them all
  slice_filename = cellfun(@(x) fullfile(patient_dir, x), {slice_file_list.name}, 'UniformOutput', false);
  if iscell(slice_filename) && length(slice_filename) == 1
    slice_filename = slice_filename{1};
  end
else
  % Which slices are combined slices
  combined_slice_idx = ~cellfun(@isempty, strfind({slice_file_list.name}, 'combined'));
  
  if sum(combined_slice_idx) == 0
    error('getSlice:multipleSlices', 'Multiple slices found in %s; none are combined and b_allow_multiple_slices is false', patient_dir);
  elseif sum(combined_slice_idx) == 1
    % If there are multiple slices and only one combined slice, return the
    % combined slice
    slice_filename = fullfile(patient_dir, slice_file_list(combined_slice_idx).name);
  else
    error('Multiple combined slices found in %s', patient_dir);
  end
end

%% Also get roi and PK filenames
roi_filename = strrep(slice_filename, 'slice', 'roi');
if ~exist(roi_filename, 'file')
  roi_filename = '';
end

pk_filename = strrep(slice_filename, 'slice', 'pharmacokinetic');
if ~exist(pk_filename, 'file')
  pk_filename = '';
end
