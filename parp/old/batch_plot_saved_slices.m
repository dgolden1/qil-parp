function batch_plot_saved_slices(str_pre_or_post_chemo)
% Plot saved slices for patients

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Setup
close all;

output_dir = '/Users/dgolden/temp/parp_matlab_slices';
if ~exist(output_dir, 'dir')
  mkdir(output_dir);
end

%% Loop
patient_ids = get_processed_patient_list(str_pre_or_post_chemo);

for kk = 1:length(patient_ids)
  this_patient_id = patient_ids(kk);
  slice_filename = get_slice_filename(this_patient_id, str_pre_or_post_chemo);
  
  fs = load(slice_filename);
  
  sfigure(1);
  clf;
  [x, y, x_label, y_label, slice_location, slice_label] = get_img_coords(fs.x_mm, fs.y_mm, fs.z_mm);
  idx_plot = find(fs.t > 60, 1, 'first');
  imagesc(x, y, fs.slices(:,:,idx_plot));
  cax = quantile(flatten(fs.slices(:,:,idx_plot)), [0.01 0.99]);
  caxis(cax);
  axis xy equal tight;
  colormap gray;
  xlabel(x_label);
  ylabel(y_label);
  title(sprintf('Patient %03d  %s = %0.1f  t = %0.0f s', this_patient_id, slice_label, slice_location, fs.t(idx_plot)));
  increase_font;
  
  output_filename = fullfile(output_dir, sprintf('%03d_post_chemo', this_patient_id));
  print_trim_png(output_filename);
  fprintf('Saved %s (%d of %d)\n', output_filename, kk, length(patient_ids));
end
