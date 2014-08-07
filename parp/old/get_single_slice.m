function [slices, x_mm, y_mm, z_mm, t, info] = get_single_slice(dicom_dir, slice_mm, output_dir)
% Function to get a single time series slice in X from a directory of
% DCE-MRI DICOM files
% [slices, x_mm, y_mm, z_mm, t, info] = get_single_slice(dicom_dir, slice_mm)
%
% INPUTS
% dicom_dir: all the dcm files should be in here
% slice_mm: SliceLocation value of the desired slice (mm)
% 
% OUTPUTS
% slices: an NxMxR matrix of NxM slices of DCE-MRI values, once for each
%  of R time points
% y_mm and z_mm: the DICOM y and z values for each slice (mm)
% t: the time of each slice in sec
% info: the DICOM header for each slice

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
patient_dir_name = just_filename(fileparts(fileparts(dicom_dir)));
patient_id = get_patient_id_from_name(patient_dir_name);

if ~exist('output_dir', 'var') || isempty(output_dir)
  % Assume dicom_dir structure is:
  % /filesystem/dicom_anon/patientname/sequence/series/*.dcm
  output_dir = get_patient_dir_from_id(patient_id, 'pre');
end

[dicom_dir_up, dicom_sequence_name] = fileparts(dicom_dir);
slice_mat_filename = sprintf('%s_slice_%04.1fmm.mat', strrep(dicom_sequence_name, ' ', '_'), slice_mm);
slice_mat_full_filename = fullfile(output_dir, slice_mat_filename);

b_parallel = true;
if b_parallel && matlabpool('size') == 0
  matlabpool('open');
end

%% If a processed .mat file already exists, return it
if exist(slice_mat_full_filename, 'file')
  t_matfileload_start = now;
  load(slice_mat_full_filename);
  fprintf('Loaded %s in %s\n', just_filename(slice_mat_full_filename), time_elapsed(t_matfileload_start, now));
  return
end

%% Get list of DICOM files
% If there's no pre-processed MAT file, search through the DICOM files
d = dir(fullfile(dicom_dir, '*.dcm'));
if isempty(d)
  error('No DICOM files in %s', dicom_dir);
end

%% Load DICOM headers
t_file_start = now;

% Loading the DICOM info from each file is what takes the longest amount of
% time; save time by saving the full info struct into a file
% NOTE: if any DICOM files change, this info file will need to be
% re-generated (just delete the old one and re-run this function)
info_filename = fullfile(output_dir, [dicom_sequence_name '_info.mat']);
info = struct([]);
if exist(info_filename, 'file')
  fprintf('Loading DICOM headers from %s...\n', info_filename);
  load(info_filename);
else
  fprintf('Reading DICOM headers from DCM files...\n');
  
  progress_temp_dirname = parfor_progress_init;
  parfor kk = 1:length(d)
    t_start = now;
    
    thisinfo = dicominfo(fullfile(dicom_dir, d(kk).name));
    
    % Images with key frames have an additional structure field, which
    % other images don't have; remove it, or we can't store image info in a
    % structure array
    if isfield(thisinfo, 'FrameOfInterestDescription')
      thisinfo = rmfield(thisinfo, 'FrameOfInterestDescription');
    end
    
    % Get rid of private fields, which we don't use and which can be very large
    fn = fieldnames(thisinfo);
    fn_private = fn(cellfun(@(x) ~isempty(regexp(x, '^Private', 'once')), fn));
    thisinfo = rmfield(thisinfo, fn_private);
  
    info_cell{kk} = thisinfo;
    
    iteration_number = parfor_progress_step(progress_temp_dirname, kk);
    fprintf('Got info for DICOM file %d of %d in %s\n', iteration_number, length(d), time_elapsed(t_start, now));
  end
  parfor_progress_cleanup(progress_temp_dirname);
  
  % Then, using a regular for loop, cram them into a struct vector
  info = info_cell{1};
  for kk = 2:length(info_cell)
    [info, thisinfo] = homogenize_structure_fields(info, info_cell{kk});
    info = [info thisinfo];
  end
  
  save(info_filename, 'info');
  fprintf('Saved %s\n', info_filename);
end

%% Massage header info and parse out what we want
% Sometimes in Spiral scans, wash-in and wash-out are combined into a
% single study; make sure we only choose the wash-in files. The "DISCO" 3T
% series is just called DISCO and includes both
% wash_in_idx = ~cellfun(@isempty, strfind(lower({info.SeriesDescription}), 'wash in')) | ...
%               ~cellfun(@isempty, strfind(lower({info.SeriesDescription}), 'disco'));
% if sum(wash_in_idx) > 0
%   info = info(wash_in_idx);
% end

slice_locations_full = get_slice_location(info);

slice_datenums = get_dicom_time(info, patient_id);

% Remove slices with invalid times
idx_valid = isfinite(slice_datenums);
info = info(idx_valid);
slice_datenums = slice_datenums(idx_valid);
slice_locations_full = slice_locations_full(idx_valid);


start_datenum = min(slice_datenums);

% Sort by acquisition time, then slice location
slice_locations_full_orig = slice_locations_full;
slice_datenums_orig = slice_datenums;
info = sort_by_time_then_loc(slice_datenums_orig, slice_locations_full_orig, info);
slice_locations_full = sort_by_time_then_loc(slice_datenums_orig, slice_locations_full_orig, slice_locations_full);
slice_datenums = sort_by_time_then_loc(slice_datenums_orig, slice_locations_full_orig, slice_datenums);

if length(info) > 1 && ~all(diff(slice_datenums) >= 0)
  % This should never happen, due to the above sorting
  error('Some acquisition times are decreasing');
end

slice_times_full = (slice_datenums - start_datenum)*86400; % Seconds

slice_locations_unique = unique(slice_locations_full);
closest_slice_idx = interp1(slice_locations_unique, 1:length(slice_locations_unique), slice_mm, 'nearest');
this_slice_idx = find(slice_locations_full == slice_locations_unique(closest_slice_idx));

% Sometimes wash-in and wash-out are combined into a single study, in which
% case the TriggerTime values will be repeated.  Just take the first set.
% NOTE: I didn't verify why there are repeated time points -- 2011-09-11
if length(this_slice_idx) > length(unique(slice_times_full(this_slice_idx)))
  this_slice_idx = this_slice_idx(1:find(diff(slice_times_full(this_slice_idx)) < 0));
end

info = info(this_slice_idx);
t = slice_times_full(this_slice_idx);

%% Load the DICOM data
slices(:, :, 1) = dicomread(info(1).Filename);
slices(:, :, 2:length(this_slice_idx)) = 0;
for kk = 2:length(info)
  slices(:,:,kk) = dicomread(info(kk).Filename);
end
slices = double(slices);

fprintf('Loaded %d DICOM images in %s\n', length(info), time_elapsed(t_file_start, now));

%% Determine x, y, z coordinates (mm) for each voxel
[x_mm, y_mm, z_mm, slice_plane] = get_dicom_xyz(info);

%% Save
save(slice_mat_full_filename, 'info', 'slices', 'x_mm', 'y_mm', 'z_mm', 'slice_plane', 't', 'start_datenum');
fprintf('Wrote %s\n', slice_mat_full_filename);

function vec_sorted = sort_by_time_then_loc(times, locations, vec_unsorted)
%% Function: sort slices by time and then location

[~, sort_idx_loc] = sort(locations);
[~, sort_idx_time] = sort(times(sort_idx_loc));

vec_sorted = vec_unsorted(sort_idx_loc);
vec_sorted = vec_sorted(sort_idx_time);

function struct_noprivate = remove_private_fields(struct_private)
% Remove "Private_..." fields from DICOM info struct

