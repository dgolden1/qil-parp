function test_rohans_code
% Test Rohan's segmentation code using empirical dye dilution parameters
% from a real lesion

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
close all;

addpath(fullfile('rohans_segmentation_code'));
addpath(fullfile('rohans_segmentation_code', 'Additional_Functions'));
addpath(fullfile('rohans_segmentation_code', 'Cluster_Verification'));

%% Load data
% do_one_run('C:\Users\Daniel\Documents\VLF\nih_k25_proposal\parp_patient_data\PARP_021_PRE_MRI\Bilat Spiral WASH IN - 56', 82);
do_one_run(fullfile(parp_patient_dir, 'PARP_023_PRE_MRI', 'Bilat Spiral WASH IN - 56'), -90);

function do_one_run(dicom_dir, x_mm)
%% One run of Rohan's code

%% Get the slice info and plot the kinetic map
[slices, y_mm, z_mm, t, info] = get_single_slice(dicom_dir, x_mm);
plot_empirical_kinetic_map(slices, y_mm, z_mm, t, info);
h_ax(1) = gca;

load(fullfile(fileparts(dicom_dir), 'roi.mat'), 'roi_mask', 'roi_poly');

hold on
plot(roi_poly.y, roi_poly.z, 'wo-');

%% Crop out just the ROI
i_mask = any(roi_mask,2);
j_mask = any(roi_mask,1);
slices_cropped = reshape(slices(i_mask, j_mask, :), [sum(i_mask) sum(j_mask) size(slices, 3)]);
y_mm_cropped = y_mm(j_mask);
z_mm_cropped = z_mm(i_mask);

%% Segment
region_map.Data = squeeze(mat2cell(slices_cropped, size(slices_cropped, 1), size(slices_cropped, 2), ones(1, size(slices_cropped, 3))));
region_map.sample_times = t/60; % minutes
output_map = Process_region_map(region_map, 'signal', 2, 9);

%% Plot
figure;
imagesc(y_mm_cropped, z_mm_cropped, output_map);
axis xy equal
title('Segmented image');
xlabel('Y (mm)');
ylabel('Z (mm)');
increase_font;
h_ax(2) = gca;

linkaxes(h_ax);
saxes(h_ax(2));
axis tight


1;
