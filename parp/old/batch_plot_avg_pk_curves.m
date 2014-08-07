function batch_plot_avg_pk_curves(str_pre_or_post_chemo, patient_ids)
% Plot lesion-averages PK curves

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Setup
close all;
output_dir = '~/temp/pk_curves';
if ~exist(output_dir, 'dir')
  mkdir(output_dir);
end

if ~exist('str_pre_or_post_chemo', 'var') || isempty(str_pre_or_post_chemo)
  str_pre_or_post_chemo = 'pre';
end

warning('off', 'get_contrast_info:unknownInfo');

%% Plot enhancement curves

if exist('patient_ids', 'var') && ~isempty(patient_ids)
  patient_ids = patient_ids;
else
  patient_ids = get_processed_patient_list(str_pre_or_post_chemo);
end

figure(1);
for kk = 1:length(patient_ids)
  t_start = now;
  
  info = [];
  [slice_filename, roi_filename] = get_slice_filename(patient_ids(kk), str_pre_or_post_chemo);
  load(slice_filename);
  load(roi_filename);
  
  enhancement = reshape(slices(repmat(roi_mask, [1, 1, length(t)])), sum(roi_mask(:)), length(t));
  avg_enhancement = mean(enhancement);
  avg_enhancement = reshape(avg_enhancement, [1, 1, length(avg_enhancement)]); % Make it look like a 1x1 slice
  
  [ktrans, ve, kep, T10, residual, model, b_known_contrast_protocol] = get_pk_params(avg_enhancement, true, t, info);
  
  
  % Plot average lesion contrast slope
  cla;
  plot(model.t_data*60, model.enhancement_data, 'ks-', 'markerfacecolor', 'w', 'markersize', 8, 'linewidth', 2);
  hold on;
  plot(model.t_fit*60, model.enhancement_fit, 'r-', 'linewidth', 2);
  grid on
  xlabel('Time (sec)');
  ylabel('Avg lesion enhancement (arbitrary units)');
  title(sprintf('Patient %03d', patient_ids(kk)));
  
  % Plot lesion empirical kinetics by color
  %plot_empirical_kinetic_map(slices, x_mm, y_mm, z_mm, t, info, 'roi_poly', roi_poly, 'roi_mask', roi_mask, 'b_zoom', true, 'h_ax', s(2))

  increase_font;
  
  output_filename = fullfile(output_dir, sprintf('%03d_pk', patient_ids(kk)));
  print_trim_png(output_filename);
  fprintf('Saved %s (%d of %d) in %s\n', output_filename, kk, length(patient_ids), time_elapsed(t_start, now));
end

warning('on', 'get_contrast_info:unknownInfo');
