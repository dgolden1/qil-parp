function batch_print_lesions_common_size(b_by_rcb)
% Print images of all of the lesions at a common size
% Will be used to sort images by morphological properties

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012

%% Setup
close all;

if ~exist('b_by_rcb', 'var') || isempty(b_by_rcb)
  b_by_rcb = false;
end

addpath(fullfile(qilsoftwareroot, 'parp'));
output_dir = fullfile(parp_patient_dir, 'manual_char_lesion_images');

if ~exist(output_dir, 'dir')
  mkdir(output_dir)
end

[patient_ids, patient_dirs] = get_processed_patient_list;

%% Print lesion maps

for kk = 1:length(patient_ids)
  this_patient_id = patient_ids(kk);
  
  print_subtraction_image(this_patient_id, output_dir, b_by_rcb, false); % Subtraction
  % print_subtraction_image(this_patient_id, output_dir, b_by_rcb, true); % Post-contrast only
  % print_kinetic_map(this_patient_id, 'ktrans', output_dir, b_by_rcb);
  % print_kinetic_map(this_patient_id, 'kep', output_dir, b_by_rcb);
  % print_kinetic_map(this_patient_id, 've', output_dir, b_by_rcb);
end

function print_subtraction_image(patient_id, output_dir, b_by_rcb, b_post_only)
%% Function: print a subtraction image

% If this patient got either a Bilat Spiral or WATER scan, they have higher
% resolution pre and post images than are available in the dynamic scan
if exist(fullfile(get_patient_dir_from_id(patient_id, 'pre'), 'pre_post'), 'dir')
  b_pre_post_img = true;
else
  b_pre_post_img = false;
end

if b_pre_post_img
  slice_filename = get_slice_filename(patient_id, [], true);
  [~, roi_filename] = get_slice_filename(patient_id, [], false);
else
  [slice_filename, roi_filename] = get_slice_filename(patient_id, [], false);
end
load(roi_filename);
load(slice_filename);
[x_coord_mm, y_coord_mm] = get_img_coords(x_mm, y_mm, z_mm);

% The ROI mask from the ROI file will have the wrong dimensions for
% PRE/POST images, since it was specified on the dynamic sequence
if b_pre_post_img
  [x_roi_px, y_roi_px] = roi_mm_to_px(x_coord_mm, y_coord_mm, roi_poly.img_x_mm, roi_poly.img_y_mm);
  roi_mask = poly2mask(x_roi_px, y_roi_px, size(slices, 1), size(slices, 2));
end

idx_pre_contrast = 1;

% Post-contrast image is the nearest one to 180 sec, or the second image,
% whichever is later
idx_post_contrast = max(2, interp1(t, 1:length(t), 180, 'nearest', 'extrap'));

img_pre_contrast = slices(:,:,idx_pre_contrast);
img_post_contrast = slices(:,:,idx_post_contrast);

if b_post_only
  img = img_post_contrast;
  img_title = sprintf('Patient %03d POST img', patient_id);
else
  if b_pre_post_img
    % Register the images. We're assuming that the ROI (which was specified on
    % the dynamic sequence, not on these PRE and POST images) is accurate on
    % the PRE image, so we move the POST image to overlap the PRE image
    if ~ishandle(2)
      figure(2);
      figure_grow(gcf, 2, 1.3);
    end

    sfigure(2); clf;
    s(1) = subplot(1, 2, 1);
    imshowpair(img_post_contrast, img_pre_contrast);
    title('Pre-registration');
    [optimizer,metric] = imregconfig('multimodal');
    optimizer.GrowthFactor = 1.01;
    t_start = now;
    img_post_contrast_registered = imregister(img_post_contrast, img_pre_contrast, 'affine', optimizer, metric);
    s(2) = subplot(1, 2, 2);
    imshowpair(img_post_contrast_registered, img_pre_contrast);
    title(sprintf('Registered in %s', time_elapsed(t_start, now)));
    linkaxes(s);
    zoom on;

    img = img_post_contrast_registered - img_pre_contrast;
  else
    img = img_post_contrast - img_pre_contrast;
  end
  
  img_title = sprintf('Patient %03d Subtraction %0.0f sec -- %0.0f sec', patient_id, t(idx_post_contrast), t(idx_pre_contrast));
end

print_one_img(img, x_coord_mm, y_coord_mm, roi_mask, roi_poly, 'sub_img', patient_id, img_title, output_dir, b_by_rcb);

1;

function print_kinetic_map(patient_id, map_name, output_dir, b_by_rcb)
%% Function print a lesion kinetic map

% Load data
[slice_filename, roi_filename, pk_filename] = get_slice_filename(patient_id);
load(slice_filename); load(roi_filename); load(pk_filename);

switch map_name
  case 'ktrans'
    map = ktrans;
  case 'kep'
    map = kep;
  case 've'
    map = ve;
  otherwise
    error('Invalid map name: %s', map_name);
end

% Resize image and ROI to common resolution
[x_coord_mm, y_coord_mm] = get_img_coords(x_mm, y_mm, z_mm);
img_res = abs(median(diff(x_coord_mm)));
scale_factor = img_res/1.5;
[img_resized, roi_mask_resized, x_coord_mm_resized, y_coord_mm_resized] = resize_img_and_roi(map, roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor, true);
map_resized = img_resized(roi_mask_resized);

% Resize slices
for kk = 1:size(slices, 3)
  this_slice_resized = imresize(slices(:,:,kk), scale_factor);
  slices_resized(1:size(this_slice_resized, 1), 1:size(this_slice_resized, 2), kk) = this_slice_resized;
end

% Create image
% img = get_map_on_gray_bg(slices(:,:,end) - slices(:,:,1), roi_mask, map);
img = get_map_on_gray_bg(slices_resized(:,:,end) - slices_resized(:,:,1), roi_mask_resized, map_resized);
img_type_str = map_name;
img_title = sprintf('Patient %03d %s [%0.1f %0.1f]', patient_id, map_name, min(map(:)), max(map(:)));

print_one_img(img, x_coord_mm_resized, y_coord_mm_resized, roi_mask_resized, roi_poly, img_type_str, patient_id, img_title, output_dir, b_by_rcb);

function print_one_img(img, x_coord_mm, y_coord_mm, roi_mask, roi_poly, img_type_str, patient_id, img_title, output_dir, b_by_rcb)
%% Function: print one image with certain color scale, zoom

cax = [min(img(roi_mask)) max(img(roi_mask))];

roi_x_center = x_coord_mm(round(mean([find(any(roi_mask, 1), 1, 'first') find(any(roi_mask, 1), 1, 'last')])));
roi_y_center = y_coord_mm(round(mean([find(any(roi_mask, 2), 1, 'first') find(any(roi_mask, 2), 1, 'last')])));

img_diameter = 50; % mm

sfigure(1); clf;

if ndims(img) == 2
  imagesc(x_coord_mm, y_coord_mm, img);
  colormap('gray');
  caxis(cax);
elseif ndims(img) == 3
  image(x_coord_mm, y_coord_mm, img);
else
  error('Weird image size (ndims=%d)', ndims(img));
end

hold on;
plot([roi_poly.img_x_mm(:); roi_poly.img_x_mm(1)], [roi_poly.img_y_mm(:); roi_poly.img_y_mm(1)], 'r', 'linewidth', 2);
axis equal tight off
xlim(roi_x_center + [-1 1]*img_diameter/2);
ylim(roi_y_center + [-1 1]*img_diameter/2);
increase_font;

if b_by_rcb
  spreadsheet_info = get_spreadsheet_info(patient_id);
  rcb = spreadsheet_info.rcb_value;
  rcb_str = sprintf('rcb_%02d_', round(rcb*10));
%   if rcb == 0
%     rcb_str = 'rcb_0_';
%   elseif rcb < 2.5
%     rcb_str = 'rcb_1_';
%   elseif isfinite(rcb)
%     rcb_str = 'rcb_2_';
%   else
%     rcb_str = 'rcb_nan_';
%   end
  
  img_title_suffix = sprintf(' RCB=%0.1f', rcb);

  this_output_dir = fullfile(output_dir, img_type_str, 'by_rcb');
else
  rcb_str = '';
  img_title_suffix = '';
  this_output_dir = fullfile(output_dir, img_type_str);
end

if ~exist(this_output_dir, 'dir')
  mkdir(this_output_dir);
end

title([img_title img_title_suffix]);
output_filename = fullfile(this_output_dir, sprintf('%s%s_%03d', rcb_str, img_type_str, patient_id));

print_trim_png(output_filename, '-r50');
fprintf('Saved %s\n', output_filename);

1;

% WRITE SUBFUNCTIONS HERE
