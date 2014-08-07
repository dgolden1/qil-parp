function batch_plot_glcm(patient_ids)
% Plot lesion maps and GLCM matrices for all lesions

% By Daniel Golden (dgolden1 at stanford dot edu) March 2012
% $Id$

%% Setup
close all;

if ~exist('patient_ids', 'var')
  patient_ids = [];
end

output_dir = fullfile(parp_patient_dir, 'glcm_images');

b_stanford_only = false;
str_pre_or_post = 'pre';

%% Get list of patients
[patient_dir_ids, ~] = get_processed_patient_list;

if ~isempty(patient_ids)
  % Parse out only patient ids requested by user
  idx = ismember(patient_dir_ids, patient_ids);
  if sum(idx) ~= length(patient_ids)
    error('Not all requested patient dirs found');
  end
  patient_dir_ids = patient_dir_ids(idx);
else
  if b_stanford_only
    % Only Stanford patients
    idx = is_stanford_scan(patient_dir_ids, str_pre_or_post);
    patient_dir_ids = patient_dir_ids(idx);
  end
end

patient_ids = patient_dir_ids(:);

%% Loop over patients
figure;
figure_grow(gcf, 1.5, 1);

for kk = 1:length(patient_ids)
  t_start = now;
  
  this_patient_id = patient_ids(kk);
  
  % Get filanems for this patient; skip if any are not found
  try
    [slice_filename, roi_filename, pk_filename] = get_slice_filename(this_patient_id, false);
  catch er
    switch er.identifier
      case {'getSlice:multipleSlices', 'getSlice:noSlices'}
        % fprintf('%s; skipping...\n', er.message);
        continue;
      otherwise
        rethrow(er);
    end
  end

  if isempty(roi_filename) || isempty(pk_filename)
    continue;
  end
  
  % Load patient data
  info = [];
  load(slice_filename);
  load(roi_filename);
  load(pk_filename);
  
  % Get empirical parameters
  slices_masked = reshape(slices(repmat(roi_mask, [1 1 length(t)])), [sum(roi_mask(:)), length(t)]);
  [wash_in_slope, wash_out_slope, area_under_curve] = get_empirical_params(slices_masked, info, t);
  
  glcm_map_names = {'ktrans', 'kep', 've', 'wash_in_slope', 'wash_out_slope', 'area_under_curve'};
  [glcm_stats, glcm] = get_lesion_glcm_properties(x_mm, y_mm, z_mm, roi_mask, roi_poly, ...
    {ktrans, kep, ve, wash_in_slope, wash_out_slope, area_under_curve}, ...
    glcm_map_names);

  clf;

  % Plot kinetic param
  param_name = 'ktrans';
  param = eval(param_name);
  
  subplot(1, 2, 1);
  [x_coord_mm, y_coord_mm, x_label, y_label] = get_img_coords(x_mm, y_mm, z_mm);
  [img, cax_param] = get_map_on_gray_bg(slices(:,:,end) - slices(:,:,1), roi_mask, param);
  image(x_coord_mm, y_coord_mm, img);
  axis xy equal
  zoom_to_lesion(x_coord_mm, y_coord_mm, roi_mask, 'r');
  xlabel(x_label);
  ylabel(y_label);
  title(sprintf('Patient %03d %s', this_patient_id, param_name));
  
  % Plot GLCM averaged over angle
  subplot(1, 2, 2);
  glcm_combined = sum(glcm{strcmp(glcm_map_names, param_name)}, 3);
  glcm_norm = glcm_combined/sum(glcm_combined(:));
  imagesc(glcm_norm);
  axis equal tight;
  colorbar;
  
  % Put GLCM stats in figure title
  fn = fieldnames(glcm_stats);
  fn = fn(~cellfun(@isempty, regexp(fn, ['^' param_name]))); % Only glcm stats for this param
  
  
  glcm_title = sprintf('GLCM\n');
  for jj = 1:length(fn)
    glcm_title = [glcm_title sprintf('%s: %0.2f\n', strrep(fn{jj}, '_', ' '), glcm_stats.(fn{jj}))];
  end
  title(glcm_title);
  
%   increase_font;
  
  output_filename = fullfile(output_dir, sprintf('%s_glcm_patient_%03d', param_name, this_patient_id));
  print('-dpng', '-r90', output_filename);
  fprintf('Saved %s in %s\n', output_filename, time_elapsed(t_start, now));
end
