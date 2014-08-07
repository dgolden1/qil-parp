function get_and_combine_slices(patient_id, str_pre_or_post_chemo, b_pre_post_only, b_plot)
% For a patient with multiple sequences, get slices for each sequence and
% combine them
% get_and_combine_slices(patient_id, str_pre_or_post_chemo, b_pre_post_only, b_plot)

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

%% Setup
if ~exist('str_pre_or_post_chemo', 'var') || isempty(str_pre_or_post_chemo)
  str_pre_or_post_chemo = 'pre';
end
if ~exist('b_pre_post_only', 'var') || isempty(b_pre_post_only)
  b_pre_post_only = false;
end
if ~exist('b_plot', 'var') || isempty(b_plot)
  b_plot = false;
end


%% Get slice location
% We need to do this BEFORE we get the patient directory, because the
% patient's matlab directory will be created in that step, and we don't
% want to create a matlab directory for a patient without a target slice

spreadsheet_info = get_spreadsheet_info(patient_id);

switch lower(str_pre_or_post_chemo)
  case 'pre'
    x_mm = spreadsheet_info.x_mm;
    y_mm = spreadsheet_info.y_mm;
    z_mm = spreadsheet_info.z_mm;
    slice_location_mm = spreadsheet_info.slice_location_mm;
  case 'post'
    x_mm = spreadsheet_info.x_mm_post;
    y_mm = spreadsheet_info.y_mm_post;
    z_mm = spreadsheet_info.z_mm_post;
    slice_location_mm = spreadsheet_info.slice_location_mm_post;
end

if any(isnan([x_mm, y_mm, z_mm]))
  error('Spreadsheet lesion X, Y, Z coordinates are invalid for patient %d', patient_id);
end

%% Get patient dir
if isnumeric(patient_id)
  b_create_matlab_dir = true;
  dicom_dir = get_dicom_dir_from_id(patient_id, str_pre_or_post_chemo, b_create_matlab_dir);
elseif ischar(patient_id) && exist(patient_id, 'dir')
  dicom_dir = patient_id;
else
  error('Unknown entry for patient_id');
end

%% Get into sequence dir
d = dir(dicom_dir);
d = d([d.isdir] & cellfun(@isempty, regexp({d.name}, '^\.', 'once'))); % Remove files and . and .. directories
if length(d) > 1
  seq_dir = uigetdir(dicom_dir, 'Choose Sequence');
else
  seq_dir = fullfile(dicom_dir, d.name);
end

if ~isdir(seq_dir)
  error('%s does not exist', seq_dir);
end

%% Choose series
d = dir(seq_dir);
d = d([d.isdir] & cellfun(@isempty, regexp({d.name}, '^\.', 'once'))); % Remove files and . and .. directories
selection = listdlg('Promptstring', sprintf('Select series for patient %d', patient_id), 'ListString', {d.name});

if isempty(selection)
  return;
end

series_partial_dir = {d(selection).name};
series_dir = cellfun(@(x) fullfile(seq_dir, x), series_partial_dir, 'UniformOutput', false);

%% Get the slices
% If we're doing just the PRE and POST scans, put them in the pre_post
% subdirectory
output_dir = get_patient_dir_from_id(patient_id, str_pre_or_post_chemo);
if b_pre_post_only
  output_dir = fullfile(output_dir, 'pre_post');
  if ~exist(output_dir, 'dir')
    mkdir(output_dir);
  end
end

for kk = 1:length(series_dir)
  get_single_slice(series_dir{kk}, slice_location_mm, output_dir);
end

output_filename = combine_slices(patient_id, output_dir);

%% Plot
if b_plot
  fs = load(output_filename);
  
  figure(1);
  clf;
  [x, y, x_label, y_label, slice_location, slice_label] = get_img_coords(fs.x_mm, fs.y_mm, fs.z_mm);
  idx_plot = find(fs.t > 60, 1, 'first');
  imagesc(x, y, fs.slices(:,:,idx_plot));
  axis xy equal tight;
  colormap gray;
  xlabel(x_label);
  ylabel(y_label);
  title(sprintf('Patient %03d  %s = %0.1f  t = %0.0f s', patient_id, slice_label, slice_location, fs.t(idx_plot)));
  increase_font;
  
  1;
end
