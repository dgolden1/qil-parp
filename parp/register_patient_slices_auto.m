function register_patient_slices_auto(patient_id, b_make_backup)
% Register each time point of the patient's slices, making a backup if
% requested

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Setup
close all;
output_dir = '~/temp/patient_registration_movies';
if ~exist(output_dir, 'dir')
  mkdir(output_dir);
end

b_show_impairs = false;

%% Perform registration
t_start = now;

[slice_filename, roi_filename] = get_slice_filename(patient_id);
load(slice_filename, 'slices', 't', 'x_mm', 'y_mm', 'z_mm');
load(roi_filename, 'roi_mask');
slices_new = slices;

% Image registration configuration
% [optimizer, metric] = imregconfig('monomodal');
[optimizer, metric] = imregconfig('multimodal');
optimizer.GrowthFactor = 1.1;
optimizer.MaximumIterations = 100;

if b_show_impairs
  figure;
  figure_grow(gcf, 2, 1.5);
end
for kk = 2:size(slices, 3)
  t_slice_start = now;
  t_start = now;
  [slices_new(:,:,kk), tform] = imregister(slices_new(:,:,kk), slices_new(:,:,kk-1), 'affine', optimizer, metric, 'DisplayOptimization', false);
  
  if b_show_impairs
    clf;
    super_subplot(1, 2, 1);
    imshowpair(slices(:,:,kk-1), slices(:,:,kk));
    title('Original');
    super_subplot(1, 2, 2);
    imshowpair(slices_new(:,:,kk-1), slices_new(:,:,kk));
    title('Registered');
  end
  
  fprintf('Registered slice %d of %d in %s\n', kk, size(slices, 3), time_elapsed(t_slice_start, now));
end

fprintf('Finished slice registration in %s\n', time_elapsed(t_start, now));

%% Make before and after movie
[x_coord_mm, y_coord_mm] = get_img_coords(x_mm, y_mm, z_mm);

output_filename_before = fullfile(output_dir, sprintf('%03d_0_before.avi', patient_id));
movie_title_prefix_before = sprintf('%03d before', patient_id);
make_slice_movie(slices, t, x_coord_mm, y_coord_mm, roi_mask, output_filename_before, movie_title_prefix_before);

output_filename_after = fullfile(output_dir, sprintf('%03d_1_after.avi', patient_id));
movie_title_prefix_after = sprintf('%03d after', patient_id);
make_slice_movie(slices_new, t, x_coord_mm, y_coord_mm, roi_mask, output_filename_after, movie_title_prefix_after);

%error('Continue here');
