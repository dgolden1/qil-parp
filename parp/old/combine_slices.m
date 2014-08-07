function output_filename = combine_slices(patient_id, input_output_dir, b_overwrite_existing)
% Combine slices for a patient whose dynamic scan is in two or more series
% combine_slices(patient_id, input_output_dir)

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

%% Setup
if ~exist('input_output_dir', 'var') || isempty(input_output_dir)
  input_output_dir = get_patient_dir_from_id(patient_id, 'pre');
end
if ~exist('b_overwrite_existing', 'var') || isempty(b_overwrite_existing)
  b_overwrite_existing = false;
end

%% Get list of slice files
d = dir(fullfile(input_output_dir, '*slice*'));

% Remove any combined slices we picked up
d = d(cellfun(@(x) isempty(strfind(x, 'combined')), {d.name}));

if length(d) == 0
  fprintf('No slice files found in %s\n', input_output_dir);
  output_filename = '';
  
  return;
elseif length(d) == 1
  fprintf('Only one slice file found in %s\n', input_output_dir);
  output_filename = fullfile(input_output_dir, d.name);
  
  return;
end

%% Make sure all slices are at the same location
% This is in the slice filename, e.g.,
% SERIES_NAME_slice_[-79.9mm]
idx_1 = strfind(d(1).name, 'slice');
slice_location_name = d(1).name(idx_1:end);

for kk = 2:length(d)
  idx = strfind(d(kk).name, 'slice');
  
  if ~strcmp(d(kk).name(idx:end), slice_location_name);
    error('Not all slices are at same location (slice 1: %s, slice %d: %s)', ...
      slice_location_name(6:end), kk, d(kk).name(idx+5:end));
  end
end

%% Load slices
for kk = 1:length(d)
  slice_files(kk) = load(fullfile(input_output_dir, d(kk).name));
end

% Sort slices by start_datenum
[~, idx_sort] = sort([slice_files.start_datenum]);
slice_files = slice_files(idx_sort);

for kk = 1:length(d)
  slice_file_times{kk} = slice_files(kk).start_datenum + slice_files(kk).t;  
end

% Make sure slice parameters are the same
if ~all(strcmp({slice_files(2:end).slice_plane}, slice_files(1).slice_plane))
  error('Slices must be in the same plane');
end
if ~all(cellfun(@(x) all(x == slice_files(1).x_mm), {slice_files(2:end).x_mm})) || ...
   ~all(cellfun(@(x) all(x == slice_files(1).y_mm), {slice_files(2:end).y_mm})) || ...
   ~all(cellfun(@(x) all(x == slice_files(1).z_mm), {slice_files(2:end).z_mm}))
  error('Slice coordinates must agree');
end

%% Arrange slices into a common struct
slices_common = slice_files(1);
for kk = 2:length(slice_files)
  this_num_slices = length(slice_files(kk).t);
  this_common_idx = (length(slices_common.t) + 1):(length(slices_common.t) + this_num_slices);
  slices_common.slices(:, :, this_common_idx) = slice_files(kk).slices;
  slices_common.t(this_common_idx) = (slice_files(kk).start_datenum + slice_files(kk).t/86400 - slices_common.start_datenum)*86400;
  
  % Make sure that the common info and the new info to be appended are not
  % dissimilar structures
  [slices_common.info, this_info] = homogenize_structure_fields(slices_common.info, slice_files(kk).info);
  slices_common.info = [slices_common.info this_info];
end

% Make sure slice times are monotonically increasing
if ~all(diff(slices_common.t) > 0)
  error('Combined slice times must be monotonically increasing');
end

%% Register patients who moved between the pre-contrast and post-contrast images
% if patient_id == 7
%   fprintf('Fixing mis-registered pre and post contrast images for patient %d\n', patient_id);
%   old_slices = slices_common.slices; % For debugging
%   slices_common.slices = register_pre_post(slices_common.slices, slices_common.t);
% end

%% Save combined slices
[~, patient_name] = fileparts(input_output_dir);
if strcmp(patient_name, 'pre_post')
  patient_name = sprintf('%03dPRE_pre_post', patient_id);
end
output_filename = fullfile(input_output_dir, sprintf('%s_combined_%s', patient_name, slice_location_name));

if exist(output_filename, 'file') && ~b_overwrite_existing
  error('Output file %s exists', output_filename);
end

save(output_filename, '-struct', 'slices_common');
fprintf('Saved %s\n', output_filename);

1;
