function test_nicks_code
% Function to test Nick Huches' pharmacokinetic modeling code

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
close all;

addpath(fullfile('nicks_PK_code', 'DCE'));
addpath(fullfile('nicks_PK_code', 'LS'));
addpath(fullfile('rohans_segmentation_code'));
addpath(fullfile('rohans_segmentation_code', 'Additional_Functions'));
addpath(fullfile('rohans_segmentation_code', 'Cluster_Verification'));

% True to load pre-saved PK parameters; false to calculate them
b_use_saved_pk = true;
% b_use_saved_pk = false;

%% Run on test data
% load C:\Users\Daniel\Documents\VLF\dgolden_papers\proposals\2011-10-12_NIH_K25\software\nicks_PK_code\Matlab_Data\DCE_MRI_Struct.mat

% [Ktrans, ve, kep, residual] = fit_Tofts_model_using_known_T10(DCE_MRI_Struct, 1:5, 1.0, 5, 0.05:0.05:1.5, 0.05:0.05:3, [0.7 0.3 1.4 1.1 0.5]);
% [Ktrans, ve, kep, T10, residual] = fit_Tofts_model_and_T10(DCE_MRI_Struct, [1:5], 1.0, 5, [0.05:0.05:1.5], [0.05:0.05:3], [0.05:0.1:3]);

% i = 200:250;
% j = 275:325;
% [I, J] = ndgrid(i, j);
% voxel_idx = sub2ind(size(DCE_MRI_Struct.Data{1}), I(:), J(:));
% [Ktrans, ve, kep, T10, residual] = fit_Tofts_model_and_T10(DCE_MRI_Struct, voxel_idx, 1.0, 1, [0.05:0.05:1.5], [0.05:0.05:3], [0.05:0.1:3]);

%% Load data
% do_one_run('C:\Users\Daniel\Documents\VLF\nih_k25_proposal\parp_patient_data\PARP_021_PRE_MRI\Bilat Spiral WASH IN - 56', 82);
do_one_run(fullfile(parp_patient_dir, 'PARP_023_PRE_MRI', 'Bilat Spiral WASH IN - 56'), -90, b_use_saved_pk);

function do_one_run(dicom_dir, x_mm, b_use_saved_pk)
%% One run of Nick's code

%% Get the slice info and plot the kinetic map
[slices, y_mm, z_mm, t, info] = get_single_slice(dicom_dir, x_mm);
rgb_img = plot_empirical_kinetic_map(slices, y_mm, z_mm, t, info, 'b_plot', true);
h_ax(1) = gca;

load(fullfile(fileparts(dicom_dir), 'roi.mat'), 'roi_mask', 'roi_poly');

hold on
plot(roi_poly.y([1:end 1]), roi_poly.z([1:end 1]), 'wo-', 'markersize', 4, 'markerfacecolor', 'w');

%% Crop out just the ROI
i_mask = any(roi_mask,2);
j_mask = any(roi_mask,1);

% Pad by one pixel so area outside region is contiguous (for segmentation)
i_mask([find(i_mask, 1, 'first') - 1, find(i_mask, 1, 'last') + 1]) = true;
j_mask([find(j_mask, 1, 'first') - 1, find(j_mask, 1, 'last') + 1]) = true;

slices_cropped = reshape(slices(i_mask, j_mask, :), [sum(i_mask) sum(j_mask) size(slices, 3)]);
y_mm_cropped = y_mm(j_mask);
z_mm_cropped = z_mm(i_mask);
roi_mask_cropped = interpn(1:size(slices, 1), 1:size(slices, 2), roi_mask, find(i_mask), find(j_mask), 'nearest');


%% Build up the necessary struct for Nick's PK code
% DCE_MRI_Struct.Data = squeeze(mat2cell(slices, size(slices, 1), size(slices, 2), ones(1, size(slices, 3))));
DCE_MRI_Struct.Data = squeeze(mat2cell(slices_cropped, size(slices_cropped, 1), size(slices_cropped, 2), ones(1, size(slices_cropped, 3))));
DCE_MRI_Struct.sample_times = t/60; % min
DCE_MRI_Struct.is_baseline_volume = true(size(t)); DCE_MRI_Struct.is_baseline_volume(t > 40) = false;
DCE_MRI_Struct.field_strength = info(1).MagneticFieldStrength; % Tesla
DCE_MRI_Struct.flip_angle = info(1).FlipAngle; % deg
DCE_MRI_Struct.TR = info(1).RepetitionTime/1e3; % sec
DCE_MRI_Struct.TE = info(1).EchoTime/1e3; % sec
DCE_MRI_Struct.Gd_dose = 0.1; % mmol/kg
[DCE_MRI_Struct.R1, DCE_MRI_Struct.R2] = get_CA_relaxivities('magnevist', DCE_MRI_Struct.field_strength);

voxel_idx = find(roi_mask_cropped);


%% Get the PK parameters
if b_use_saved_pk
  load C:\Users\Daniel\temp\blah.mat;
else
  t_tofts_start = now;
  AIF_onset_time = 40/60; % time of contrast agent injection, min
  num_runs_optimizer = 3;
  init_Ktrans = 0.05:0.05:1.5;
  init_kep = 0.05:0.05:3;
  init_T10 = 0.05:0.1:3;
  % [Ktrans, ve, kep, T10, residual] = fit_Tofts_model_and_T10(DCE_MRI_Struct, voxel_idx, AIF_onset_time, num_runs_optimizer, init_Ktrans, init_kep, init_T10);

  T10 = ones(size(voxel_idx));
  [Ktrans, ve, kep, residual] = fit_Tofts_model_using_known_T10(DCE_MRI_Struct, voxel_idx, AIF_onset_time, num_runs_optimizer, init_Ktrans, init_kep, T10);

  fprintf('Processed %d voxels in %s\n', length(voxel_idx), time_elapsed(t_tofts_start, now));
end


%% Create PK images
im_ktrans = nan(size(slices_cropped(:,:,1)));
im_ktrans(voxel_idx) = Ktrans;
im_kep = nan(size(slices_cropped(:,:,1)));
im_kep(voxel_idx) = kep;
im_T10 = nan(size(slices_cropped(:,:,1)));
im_T10(voxel_idx) = T10;


%% Plot PK params
figure;
subplot(2, 2, 1);
image(y_mm_cropped, z_mm_cropped, reshape(rgb_img(i_mask, j_mask, :), [sum(i_mask), sum(j_mask), 3]));
axis xy equal tight
title('Mapped lesion');
xlabel('Y (mm)');
ylabel('Z (mm)');
colorbar

subplot(2, 2, 2);
[new_im_ktrans, new_cmap, new_cax] = colormap_white_bg(im_ktrans, jet, quantile(im_ktrans(:), [0 1]));
imagesc(y_mm_cropped, z_mm_cropped, new_im_ktrans);
colormap(new_cmap);
caxis(new_cax);
axis xy equal tight
title('K^{trans}');
xlabel('Y (mm)');
ylabel('Z (mm)');
colorbar

subplot(2, 2, 3);
[new_im_kep, new_cmap, new_cax] = colormap_white_bg(im_kep, jet, quantile(im_kep(:), [0 1]));
imagesc(y_mm_cropped, z_mm_cropped, new_im_kep);
caxis(new_cax);
axis xy equal tight
title('K_{ep}');
xlabel('Y (mm)');
ylabel('Z (mm)');
colorbar;

subplot(2, 2, 4);
% [new_im_T10, new_cmap, new_cax] = colormap_white_bg(im_T10, jet, quantile(im_T10(:), [0 1]));
% caxis(new_cax);
% imagesc(y_mm_cropped, z_mm_cropped, new_im_T10);
imagesc(y_mm_cropped, z_mm_cropped, im_T10);
axis xy equal tight
title('T_{10}');
xlabel('Y (mm)');
ylabel('Z (mm)');
colorbar;

increase_font;


%% Segment image using Rohan's code
% This might be a better technique: http://blogs.mathworks.com/steve/2006/06/02/cell-segmentation/

region_map = repmat(struct('Ktrans', nan, 'kep', nan, 'T10', nan), size(im_ktrans));
for kk = 1:size(im_ktrans, 1)
  for jj = 1:size(im_ktrans, 2)
    if any(isnan([im_ktrans(kk, jj) im_kep(kk, jj) im_T10(kk, jj)]))
      region_map(kk, jj).Ktrans = 0;
      region_map(kk, jj).kep = 0;
      region_map(kk, jj).T10 = 0;
    else
      region_map(kk, jj).Ktrans = im_ktrans(kk, jj);
      region_map(kk, jj).kep = im_kep(kk, jj);
      region_map(kk, jj).T10 = im_T10(kk, jj);
    end
  end
end
data_type = 'params';
nClusters_low = 4;
nClusters_high = 9;

output_map = Process_region_map(region_map, data_type, nClusters_low, nClusters_high);

figure;
imagesc(y_mm_cropped, z_mm_cropped, output_map);
axis xy equal tight
title('Segmented image');
xlabel('Y (mm)');
ylabel('Z (mm)');
increase_font;


%% Computer texture for Ktrans and kep using gray-level co-occurrence matrices
warning('off', 'Images:graycomatrix:scaledImageContainsNan'); % We know the image has NaNs
glcm_ktrans = graycomatrix(im_ktrans, 'Offset', [0 1; -1 1; -1 0; -1 -1]); % 0, 45, 90 and 135 degrees
glcm_ktrans_stats = graycoprops(glcm_ktrans)
glcm_kep = graycomatrix(im_kep, 'Offset', [0 1; -1 1; -1 0; -1 -1]);
glcm_kep_stats = graycoprops(glcm_kep)
warning('on', 'Images:graycomatrix:scaledImageContainsNan');

%% Save data
output_filename = 'C:\Users\Daniel\temp\blah.mat';
save(output_filename);
fprintf([strrep(output_filename, '\', '\\') '\n']);

1;
