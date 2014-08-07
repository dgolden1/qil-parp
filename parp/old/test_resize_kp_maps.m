function test_resize_kp_maps(patient_id, scale_factor)
% Determine whether it matters whether I resize images before or after
% calculating kinetic maps

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Setup
if ~exist('patient_id', 'var') || isempty(patient_id)
  patient_id = 19;
end
if ~exist('scale_factor', 'var') || isempty(scale_factor)
  scale_factor = 0.5;
end

%% Original
[slice_filename, roi_filename, pk_filename] = get_slice_filename(patient_id);
info = [];
load(slice_filename, 'slices', 'info', 'x_mm', 'y_mm', 'z_mm', 't');
load(roi_filename, 'roi_poly', 'roi_mask');
load(pk_filename, 've', 'kep', 'ktrans');

[x_coord_mm, y_coord_mm, x_label, y_label] = get_img_coords(x_mm, y_mm, z_mm);
bg_img = slices(:,:,end) - slices(:,:,1);
plot_pk_params(x_coord_mm, y_coord_mm, x_label, y_label, bg_img, roi_mask, ktrans, kep, ve, 'b_zoom', true);
print_trim_png(sprintf('~/temp/pk_%03d_sc%03d_original', patient_id, scale_factor*100));

%% Image -> PK map -> Resize
b_contstrain_output = false;

% Resize PK maps
[img_resized, roi_mask_resized, x_coord_mm_resized, y_coord_mm_resized] = resize_img_and_roi(ktrans, roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor, b_contstrain_output);
ktrans_post_resized = img_resized(roi_mask_resized);

[img_resized, roi_mask_resized, x_coord_mm_resized, y_coord_mm_resized] = resize_img_and_roi(kep, roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor, b_contstrain_output);
kep_post_resized = img_resized(roi_mask_resized);

[img_resized, roi_mask_resized, x_coord_mm_resized, y_coord_mm_resized] = resize_img_and_roi(ve, roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor, b_contstrain_output);
ve_post_resized = img_resized(roi_mask_resized);

for kk = 1:size(slices, 3)
  slices_resized(:,:,kk) = imresize(slices(:,:,kk), scale_factor);
end

bg_img = slices_resized(:,:,end) - slices_resized(:,:,1);
plot_pk_params(x_coord_mm_resized, y_coord_mm_resized, x_label, y_label, bg_img, roi_mask_resized, ktrans_post_resized, kep_post_resized, ve_post_resized, 'b_zoom', true);
print_trim_png(sprintf('~/temp/pk_%03d_sc%03d_calc_then_resize', patient_id, scale_factor*100));

%% Image -> Resize -> PK map
[ktrans_pre_resized, ve_pre_resized, kep_pre_resized] = get_pk_params(slices_resized, roi_mask_resized, t, info);

bg_img = slices_resized(:,:,end) - slices_resized(:,:,1);
plot_pk_params(x_coord_mm_resized, y_coord_mm_resized, x_label, y_label, bg_img, roi_mask_resized, ktrans_pre_resized, kep_pre_resized, ve_pre_resized, 'b_zoom', true);
print_trim_png(sprintf('~/temp/pk_%03d_sc%03d_resize_then_calc', patient_id, scale_factor*100));
