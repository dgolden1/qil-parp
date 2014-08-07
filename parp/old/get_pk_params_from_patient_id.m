function get_pk_params_from_patient_id(patient_id_or_dir, str_pre_or_post_chemo, b_overwrite, b_skip_errors, h_fig)
% Get pharmacokinetic parameters for a single lesion using Nick's code

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
if ~exist('b_overwrite', 'var') || isempty(b_overwrite)
  b_overwrite = false;
end
if ~exist('b_skip_errors', 'var') || isempty(b_skip_errors)
  b_skip_errors = false;
end
if ~exist('h_fig', 'var')
  h_fig = [];
end

if isnumeric(patient_id_or_dir)
  patient_id = patient_id_or_dir;
  patient_dir = get_patient_dir_from_id(patient_id_or_dir, str_pre_or_post_chemo);
elseif ischar(patient_id_or_dir)
  patient_dir = patient_id_or_dir;
  patient_id = get_patient_id_from_name(patient_id_or_dir);
end

%% Load data and error check
[slice_filename, roi_filename, pk_filename] = get_slice_filename(patient_id_or_dir, str_pre_or_post_chemo);

if isempty(roi_filename)
  msg = sprintf('No roi files found for patient %03d', patient_id);
  if b_skip_errors
    fprintf('%s; skipping\n', msg);
    return;
  else
    error('getPK:noROIs', msg);
  end
end

if ~isempty(pk_filename) && ~b_overwrite
  % PK file exists but overwrite flag is false
  
  msg = sprintf('PK file already exists (%s)', just_filename(pk_filename));
  if b_skip_errors
    fprintf('%s; skipping\n', msg);
    return;
  else
    error('getPK:PKFileExists', msg);
  end
elseif isempty(pk_filename)
  % Make a new PK file
  
  pk_filename = fullfile(fileparts(slice_filename), strrep(just_filename(slice_filename), 'slice', 'pharmacokinetic'));
end

% Load the slices and ROI
load(slice_filename, 'slices', 'x_mm', 'y_mm', 'z_mm', 't', 'info');
load(roi_filename, 'roi_mask');
patient_name = info(1).PatientName.FamilyName;

%% Create an expanded ROI mask in order to calculate edge features
roi_mask_extra = imdilate(roi_mask, strel('disk', 15));

%% Get PK params
[ktrans_extra, ve_extra, kep_extra, T10, residual, model, b_known_contrast_protocol] = get_pk_params(slices, roi_mask_extra, t, info);

ktrans = get_sub_mask(roi_mask_extra, roi_mask, ktrans_extra);
ve = get_sub_mask(roi_mask_extra, roi_mask, ve_extra);
kep = get_sub_mask(roi_mask_extra, roi_mask, kep_extra);

%% Plot PK maps
[x_coord_mm, y_coord_mm, x_label, y_label] = get_img_coords(x_mm, y_mm, z_mm);
plot_pk_params(x_coord_mm, y_coord_mm, x_label, y_label, slices(:,:,end), roi_mask, ktrans, kep, ve, 'b_zoom', true, 'h_fig', h_fig);
set(gcf, 'name', sprintf('%s PK Params', patient_name));

%% Save
save(pk_filename, 'roi_mask', 'roi_mask_extra', 'ktrans', 've', 'kep', 'ktrans_extra', 've_extra', 'kep_extra', ...
  'T10', 'residual', 'x_mm', 'y_mm', 'z_mm', 'model', 'b_known_contrast_protocol');
fprintf('Saved %s\n', pk_filename);

function param_sub = get_sub_mask(roi_mask_full, roi_mask, param_full)
%% Function: get a parameter defined on a mask on a sub-mask

full_img = nan(size(roi_mask_full));
full_img(roi_mask_full) = param_full;
param_sub = full_img(roi_mask);
