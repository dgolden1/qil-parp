function batch_plot_empirical_maps(str_pre_or_post_chemo, this_patient_id, b_overwrite)
% Make plots for each lesion

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup

if ~exist('b_overwrite', 'var') || isempty(b_overwrite)
  b_overwrite = true;
end

image_output_dir = fullfile(parp_patient_dir, 'images_empirical', str_pre_or_post_chemo);

patient_ids_pre = get_processed_patient_list('pre');
patient_ids_post = get_processed_patient_list('post');

% Select the given patient ID, if supplied
if exist('patient_id', 'var') && ~isempty(this_patient_id)
  patient_ids = patient_id;
elseif ismember(str_pre_or_post_chemo, {'pre', 'post'})
  patient_ids = get_processed_patient_list(str_pre_or_post_chemo);
elseif strcmp(str_pre_or_post_chemo, 'both')
  patient_ids = intersect(patient_ids_pre, patient_ids_post);
end

%% Loop
figure;

if strcmp(str_pre_or_post_chemo, 'both')
  h_ax(1) = subplot(1, 2, 1);
  h_ax(2) = subplot(1, 2, 2);
else
  h_ax = gca;
end

for kk = 1:length(patient_ids)
  t_start = now;
  
  this_patient_id = patient_ids(kk);
  image_filename = fullfile(image_output_dir, sprintf('parp_%03d_%s_empirical.png', this_patient_id, lower(str_pre_or_post_chemo)));

  % Don't plot if file exists
  if exist(image_filename, 'file') && ~b_overwrite
    continue;
  end
  
  try
    cla(h_ax);
    if strcmp(str_pre_or_post_chemo, 'both')
      plot_one_map(this_patient_id, 'pre', h_ax(1));
      plot_one_map(this_patient_id, 'post', h_ax(2));
    else
      plot_one_map(this_patient_id, str_pre_or_post_chemo, h_ax);
    end
  catch er
    if strcmp(er.identifier, 'plot_one_map:NoROI')
      fprintf('%s; skipping...\n', er.message);
      continue;
    else
      rethrow(er);
    end
  end
  
  print_trim_png(image_filename);
  fprintf('Saved %s (%d of %d) in %s\n', image_filename, kk, length(patient_ids), time_elapsed(t_start, now));
end

function plot_one_map(patient_id, str_pre_or_post_chemo, h_ax)
%% Function: plot a single kinetic map

[slice_filename, roi_filename] = get_slice_filename(patient_id, str_pre_or_post_chemo);

% for jj = 1:length(roi_file_list)
if ~isempty(roi_filename)
  load(roi_filename, 'roi_mask', 'roi_poly');
  load(slice_filename, 'slices', 'x_mm', 'y_mm', 'z_mm', 't', 'info');

  [~, ~, ~, ~, slice_location_mm] = get_img_coords(x_mm, y_mm, z_mm);

  plot_empirical_kinetic_map(slices, x_mm, y_mm, z_mm, t, info, 'roi_poly', roi_poly, ...
    'roi_mask', roi_mask, 'h_ax', h_ax, 'b_color_only_lesion', false, 'b_zoom', true);
  increase_font;

  title(sprintf('PARP %03d  %s  slice %0.1f mm', patient_id, str_pre_or_post_chemo, slice_location_mm));
else
  error('plot_one_map:NoROI', 'No ROI file found for patient %03d\n', patient_id);
end
