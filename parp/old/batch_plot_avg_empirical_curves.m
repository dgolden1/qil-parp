function batch_plot_avg_empirical_curves(str_pre_or_post_chemo, patient_ids)
% Make curves showing how empirical parameters are determined for each
% patient to ensure it's working correctly

% By Daniel Golden (dgolden1 at stanford dot edu July 2012)
% $Id$

%% Setup
close all;
output_dir = fullfile(parp_patient_dir, 'empirical_curves');
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
figure_grow(gcf, 1.75, 1);
s(1) = subplot(1, 2, 1);
s(2) = subplot(1, 2, 2);
for kk = 1:length(patient_ids)
  t_start = now;
  
  info = [];
  [slice_filename, roi_filename] = get_slice_filename(patient_ids(kk), str_pre_or_post_chemo);
  load(slice_filename);
  load(roi_filename);
  
  enhancement = reshape(slices(repmat(roi_mask, [1, 1, length(t)])), sum(roi_mask(:)), length(t));
  avg_enhancement = mean(enhancement);
  
  [t1, t2, t3] = get_empirical_time_points(info, t);
  
  % [~,  ~, slices_masked] = mask_2d_nd(slices, roi_mask);
  % [wash_in_slope, wash_out_slope, area_under_curve] = get_empirical_params(slices_masked, info, t);
  
  % Plot average lesion contrast slope
  saxes(s(1));
  cla;
  plot(t, avg_enhancement, 'ks-', 'markerfacecolor', 'w', 'markersize', 8);
  hold on;
  label_boost = diff(ylim)*0.05;
  time_pt_vec = {t1, t2, t3};
  time_pt_labels = {'t1', 't2', 't3'};
  for jj = 1:length(time_pt_vec)
    plot(time_pt_vec{jj}, interp1(t, avg_enhancement, time_pt_vec{jj}), 'ro', 'markerfacecolor', 'w', 'markersize', 8);
    text(time_pt_vec{jj}, interp1(t, avg_enhancement, time_pt_vec{jj}) + label_boost, time_pt_labels{jj}, 'color', 'r', 'horizontalalignment', 'center', 'fontweight', 'bold');
  end
  grid on
  xlabel('Time (sec)');
  ylabel('Avg lesion enhancement (arbitrary units)');
  title(sprintf('Patient %03d', patient_ids(kk)));
  
  % Plot lesion empirical kinetics by color
  plot_empirical_kinetic_map(slices, x_mm, y_mm, z_mm, t, info, 'roi_poly', roi_poly, 'roi_mask', roi_mask, 'b_zoom', true, 'h_ax', s(2))

  increase_font;
  
  output_filename = fullfile(output_dir, sprintf('%03d_empirical', patient_ids(kk)));
  print_trim_png(output_filename);
  fprintf('Saved %s (%d of %d) in %s\n', output_filename, kk, length(patient_ids), time_elapsed(t_start, now));
end

warning('on', 'get_contrast_info:unknownInfo');
