function batch_get_rois(str_pre_or_post_chemo, patient_id, b_registered_only)
% Get ROIs for all lesions

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
[patient_ids, patient_dirs] = get_processed_patient_list(str_pre_or_post_chemo);

% If patient_id is supplied as an input, process only that patient
if exist('patient_id', 'var') && ~isempty(patient_id)
  patient_dirs = patient_dirs(ismember(patient_ids, patient_id));
  patient_ids = patient_ids(ismember(patient_ids, patient_id));
end

if ~exist('b_registered_only', 'var') || isempty(b_registered_only)
  b_registered_only = false;
end

%% Choose only registered patients if requested
if b_registered_only
  idx_registered = false(size(patient_ids));
  for kk = 1:length(patient_ids)
    this_slice_filename = get_slice_filename(patient_ids(kk));
    s = whos('-file', this_slice_filename);
    if any(strcmp({s.name}, 'b_registered'))
      load(this_slice_filename, 'b_registered');
      if b_registered
        idx_registered(kk) = true;
      end
    end
  end
  
  patient_dirs = patient_dirs(idx_registered);
  patient_ids = patient_ids(idx_registered);
end
%% If this is post-chemo, exclude patients with no remaining visibile lesion
% if strcmp(str_pre_or_post_chemo, 'post')
%   si = get_spreadsheet_info(patient_ids);
%   b_has_residual_tumor = ismember({si.mri_pattern_of_response}, {'NO CHANGE',
%                                                                  'PROGRESSION',
%                                                                  'REGRESSION WITH FRAGMENTATION',
%                                                                  'REGRESSION WITHOUT FRAGMENTATION'});
%   patient_dirs = patient_dirs(b_has_residual_tumor);
%   patient_ids = patient_ids(b_has_residual_tumor);
% end

%% Add pre_post directories
patient_dirs_length = length(patient_dirs);
for kk = 1:patient_dirs_length
  if exist(fullfile(patient_dirs{kk}, 'pre_post'), 'dir')
    patient_dirs{end+1} = fullfile(patient_dirs{kk}, 'pre_post');
    patient_ids(end+1) = patient_ids(kk);
  end
end

%% Cycle through patients
for kk = 1:length(patient_dirs)
  this_patient_dir = patient_dirs{kk};
  % fprintf('Entered %s\n', this_patient_dir);
  
  try
    slice_filename = get_slice_filename(this_patient_dir, str_pre_or_post_chemo);
  catch er
    if strcmp(er.identifier, 'getSlice:multipleSlices')
      fprintf('Multiple slice files found in %s, skipping...\n', this_patient_dir);
      continue;
    else
      rethrow(er);
    end
  end
  
  roi_filename = strrep(slice_filename, 'slice', 'roi');
  if exist(roi_filename, 'file')
    fprintf('ROI file already exists (%s), skipping %d of %d...\n', just_filename(roi_filename), kk, length(patient_dirs));
    continue;
  end

  % Load the slices
  load(slice_filename, 'slices', 'x_mm', 'y_mm', 'z_mm', 't', 'info');
  
  % Get the ROI
  [roi_mask, roi_poly] = get_lesion_roi(slices, x_mm, y_mm, z_mm, t, info, patient_ids(kk), str_pre_or_post_chemo);

  % Save the ROI
  save(roi_filename, 'roi_mask', 'roi_poly', 'x_mm', 'y_mm', 'z_mm');
  fprintf('Saved %s (%d of %d)\n', roi_filename, kk, length(patient_dirs));
end
