function general_lesion_map_test(dicom_dir, center_mm)
% Make an empirical map of DCE-MRI lesion heterogeneity

% By Daniel Golden (dgolden1 at stanford dot edu) August 2011
% $Id$

%% Setup
close all;

% [~,hostname] = system('hostname');
% switch hostname(1:end-1)
%   case 'quadcoredan.stanford.edu'
%     dicom_dir = '/home/dgolden/temp/DCE_Tool';
%   case 'dantop'
%     dicom_dir = 'C:\Users\Daniel\temp\test_images';
% end

if ~exist('dicom_dir', 'var') || isempty(dicom_dir)
%   dicom_dir = 'C:\Users\Daniel\Documents\VLF\nih_k25_proposal\parp_patient_data\PARP_003_PRE_MRI\Bilat Spiral WASH IN - 56';
%   center_mm = [-83, -13, 19];

%   dicom_dir = 'C:\Users\Daniel\Documents\VLF\nih_k25_proposal\parp_patient_data\PARP_007_PRE_MRI\Bilat Spiral WASH IN - 66';
%   center_mm = [-108, -7, 30];

%   dicom_dir = 'C:\Users\Daniel\Documents\VLF\nih_k25_proposal\parp_patient_data\PARP_019_PRE_MRI\Bilat Spiral WASH IN - 56';
%   center_mm = [-110, -10, 40];

  dicom_dir = fullfile(parp_patient_dir, 'PARP_021_PRE_MRI', 'Bilat Spiral WASH IN - 56');
  center_mm = [82, -19, 15];

%   dicom_dir = 'C:\Users\Daniel\Documents\VLF\nih_k25_proposal\parp_patient_data\PARP_023_PRE_MRI\Bilat Spiral WASH IN - 56';
%   center_mm = [-90, -40, 6];
end

%% Load dicom data from dcm files
% See if there's a pre-processed MAT file for these DICOM files
[dicom_dir_up, dicom_sequence_name] = fileparts(dicom_dir);
mat_file_name = fullfile(dicom_dir_up, [dicom_sequence_name '.mat']);
if ~exist(mat_file_name, 'file')
  d = dir(fullfile(dicom_dir, '*.dcm'));

  t_file_start = now;
  h_waitbar = waitbar(0, sprintf('Loaded image %d of %d', 0, length(d)));

  im_stack(:, :, 1) = dicomread(fullfile(dicom_dir, d(1).name));
  im_stack(:, :, 2:length(d)) = 0;
  for kk = 1:length(d)
    info(kk) = dicominfo(fullfile(dicom_dir, d(kk).name));
    im_stack(:,:,kk) = dicomread(fullfile(dicom_dir, d(kk).name));

    waitbar(kk/length(d), h_waitbar, sprintf('Loaded image %d of %d', kk, length(d)));
  %   waitbar(kk/length(d));
  end
  fprintf('Loaded %d DICOM images in %s\n', length(info), time_elapsed(t_file_start, now));
  close(h_waitbar);
  
  save(mat_file_name, 'info', 'im_stack');
  fprintf('Wrote %s\n', mat_file_name);
else
  t_matfileload_start = now;
  load(mat_file_name);
  fprintf('Loaded %s in %s\n', just_filename(mat_file_name), time_elapsed(t_matfileload_start, now));
end

%% Load ROI if it exists
roi_filename = fullfile(fileparts(dicom_dir), 'roi.mat');
if exist(roi_filename, 'file')
  load(roi_filename, 'x_roi_mm', 'y_roi_mm', 'z_roi_mm');
end

%% Determine unique slice locations and trigger times
slice_locations_full = [info.SliceLocation];
trigger_times_full = [info.TriggerTime];
slice_locations = unique(slice_locations_full); % slice_idx location in Z axis (mm)
trigger_times = unique(trigger_times_full); % Time of this image from first image (ms)
spatial_resolution = info(1).SpatialResolution; % intra-slice resolution (mm)

assert(size(im_stack, 3) == length(slice_locations)*length(trigger_times));

%% Determine x, y, z coordinates (mm) for each voxel
% Based on forum post here: http://fixunix.com/dicom/50848-image-position-patient-question-easy.html
% Based on my screwing around in OsiriX, assuming a saggital view (cut with
% head up and patient facing left side of screen), X direction points
% towards the first image (patient's Left, Matlab dim 3), Y direction
% points from patient's stomach (anterior) towards patient's back
% (posterior, Matlab dim 2) and Z direction points from patient's feet
% (inferior) towards patient's head (superior, NEGATIVE Matlab dim 1)

% Plot like imagesc(y_mm, z_mm, img); axis xy;

originY = info(1).ImagePositionPatient(2);
originZ = info(1).ImagePositionPatient(3);
row = (1:size(im_stack, 1)).';
col = 1:size(im_stack, 2);
colDirX = info(1).ImageOrientationPatient(4);
colDirY = info(1).ImageOrientationPatient(5);
colDirZ = info(1).ImageOrientationPatient(6);
rowDirX = info(1).ImageOrientationPatient(1);
rowDirY = info(1).ImageOrientationPatient(2);
rowDirZ = info(1).ImageOrientationPatient(3);
spacingBetweenRows = info(1).PixelSpacing(1);
spacingBetweenCols = info(1).PixelSpacing(2);

% % Full
% [Row, Col] = ndgrid(row, col);
% y_mm = originY + Row*colDirY*spacingBetweenRows + Col*rowDirY*spacingBetweenCols;
% z_mm = originZ + Row*colDirZ*spacingBetweenRows + Col*rowDirZ*spacingBetweenCols;

% Simplified
x_mm = -slice_locations; % I don't know why this is flipped from OsiriX
y_mm = originY + col*rowDirY*spacingBetweenCols;
z_mm = originZ + row*colDirZ*spacingBetweenRows;

[Z_mm, Y_mm] = ndgrid(z_mm, y_mm);

% figure;
% imagesc(y_mm, z_mm, im_stack(:,:,629));
% axis xy
% grid on

%% Make a movie
this_slice_location = slice_locations(interp1(slice_locations, 1:length(slice_locations), -center_mm(1), 'nearest'));

figure;
h_img = imagesc(y_mm, z_mm, zeros(size(im_stack(:,:,1))));
axis equal tight xy;
xlabel('y (mm)');
ylabel('z (mm)');
colormap(gray);
caxis([0 quantile(im_stack(:), .99)]);
colorbar;

first_slice_idx = slice_locations_full == this_slice_location & trigger_times_full == trigger_times(1);
for kk = 1:length(trigger_times)
  slice_idx = slice_locations_full == this_slice_location & trigger_times_full == trigger_times(kk);
%   set(h_img, 'CData', im_stack(:, :, idx));
  set(h_img, 'CData', im_stack(:, :, slice_idx) - im_stack(:, :, first_slice_idx));
  F(kk) = getframe;
end

h_ax(1) = gca;

% movie(F, 3, 8);

%% Pick range of pixels and plot time series
slice = double(im_stack(:, :, slice_locations_full == this_slice_location));

% Whole area
x_range = 1:size(slice, 2);
y_range = 1:size(slice, 1);

[Y, X, Z] = ndgrid(y_range, x_range, 1:size(slice, 3));

% hold on;
% plot(X(:), Y(:), 'r.', 'markersize', 12);

t = trigger_times;

dilution_curves = reshape(slice, [size(slice,1)*size(slice,2), size(slice,3)]);

% Plot time curves of signal amplitude
quantiles = 1 - logspace(-2, 0, 10);
figure
plot(t/1e3/60, quantile(dilution_curves, quantiles), '-o');
grid on;
xlabel('Time (min)');
ylabel('Signal amplitude (arbitrary units)');
legend(num2str(quantiles.', '%0.2f'));

%% Get curve empirical criteria
% Criteria determined by Hauth et al., 2008, 10.1016/j.ejrad.2007.05.026

t1 = 1e3*60*0.65; % Time of injection, ms
t2 = 1e3*60*1.2; % Time midpoint (where plateau may begin, ms)
t3 = max(trigger_times); % End time (ms)

ampl1 = interpn(1:size(slice, 1), 1:size(slice, 2), trigger_times, slice, X(:,:,1), Y(:,:,1), t1*ones(size(X(:,:,1))));
ampl2 = interpn(1:size(slice, 1), 1:size(slice, 2), trigger_times, slice, X(:,:,1), Y(:,:,1), t2*ones(size(X(:,:,1))));
ampl3 = interpn(1:size(slice, 1), 1:size(slice, 2), trigger_times, slice, X(:,:,1), Y(:,:,1), t3*ones(size(X(:,:,1))));

slope1 = (ampl2 - ampl1)/(t2 - t1)*1e3*60; % Contrast units/min
slope2 = (ampl3 - ampl2)/(t3 - t2)*1e3*60;

%% Plot the dye dilution curve for a single pixel
if false
  [myy, myz] = ginput(1);
  my_curve = squeeze(interpn(z_mm, y_mm, trigger_times, slice, myz, myy, trigger_times));
  figure;
  plot(trigger_times/1e3/60, my_curve, '-o'); grid on;
  hold on
  plot([t1 t2 t3]/1e3/60, interp1(trigger_times, my_curve, [t1 t2 t3]), 'ro');
  xlabel('Time (min)');
end

%% Color pixels according to curves
% Exclude this area of the image when calculating colors, which includes the heart
idx_noheart = true(size(slice(:,:,1)));
% idx_noheart(X(:,:,1).' > 150) = false;

% HSV color
% Hue: initial slope
% Saturation (0=gray, 1=color): initial value
% Value (0=dark, 1=bright): wash-out slope
cmap_hsv = rgb2hsv(jet(64));
cmap_hsv(:,2:3) = 1;
cmap_hsv = flipud(unique(cmap_hsv, 'rows'));

% min_slope2 = min(slope2(idx_noheart)); % Set min/max by visible range
% max_slope2 = max(slope2(idx_noheart));

min_slope2 = -500; % Set min/max by hard limits (contrast units/min)
max_slope2 = 500;
max_slope1 = quantile(flatten(slope1(idx_noheart)), 0.99);
min_slope1 = min(slope1(idx_noheart));


V = (slope1 - min_slope1)/(max_slope1 - min_slope1);
V = max(min(V, 1), 0); % Clip out-of-range values

% S = (ampl1 - min(ampl1(idx_noheart)))/(max(ampl1(idx_noheart)) - min(ampl1(idx_noheart)));
% S = (ampl2 - min(ampl2(idx_noheart)))/(max(ampl2(idx_noheart)) - min(ampl2(idx_noheart)));
S = ones(size(slope1));

H_idx = (slope2 - min_slope2)/(max_slope2 - min_slope2);
H = interp1(linspace(0, 1, size(cmap_hsv, 1)), cmap_hsv(:,1), H_idx, 'linear', 'extrap');
H = max(min(H, 1), 0); % Clip out-of-range values

rgb_img = permute(reshape(hsv2rgb([H(:) S(:) V(:)]), size(slope1, 1), size(slope1, 2), 3), [2 1 3]);
rgb_img = max(min(rgb_img, 1), 0);

figure;
subplot(1, 4, 1:3);
image(y_mm, z_mm, rgb_img);
axis equal tight xy;
xlabel('Y (mm)');
ylabel('Z (mm)');
title('Image colored by empirical dye dilution curve');
h_ax(2) = gca;
set(gca, 'tag', 'im_mapped');
linkaxes(h_ax);
zoom on;

% Colorbar
subplot(1, 4, 4);
cmap = hsv2rgb(cmap_hsv);
clim = [min_slope2 max_slope2]; % Contrast units/msec -> Contrast units/min
c = image(1, linspace(clim(1), clim(2), 64), permute(cmap, [1 3 2]));
axis xy;
set(gca, 'xtick', [], 'yaxislocation', 'right');
ylabel(gca, 'Wash out slope (contrast units/min)');

increase_font;

%% Select and plot ROI
% roi_mask = select_and_plot_roi(findobj('tag', 'im_mapped'), rgb_img, y_mm, z_mm);

%% Group regions using Rohan's code
addpath(fullfile('rohans_segmentation_code'));
addpath(fullfile('rohans_segmentation_code', 'Additional_Functions'));
addpath(fullfile('rohans_segmentation_code', 'Cluster_Verification'));

region_map.sample_times = trigger_times/1e3;
region.map.Data = reshape(slice(repmat(roi_mask, [1 1 3])), [sum(roi_mask(:)) size(slice, 3)]);
region_map = Process_region_map(region_map, data_type, nClusters_low, nClusters_high);

%% Calculate PK parameters using Nick's code
addpath(fullfile('nicks_PK_code', 'LS'));
addpath(fullfile('nicks_PK_code', 'DCE'));

error('Continue here');

function roi_mask = select_and_plot_roi(img_ax, rgb_img, y_mm, z_mm, y_roi_mm, z_roi_mm)
%% Select an ROI and plot only those pixels

if ~exist('y_roi_mm', 'var') || isempty(y_roi_mm)
  % Manually choose ROI
  [y_roi_mm, z_roi_mm] = ginput;
end

% Plot ROI on original image
saxes(img_ax);
hold on;
plot(y_roi_mm([1:end 1]), z_roi_mm([1:end 1]), 'wo-');

% Mask ROI
% Get ROI in pixels (not necessarily rounded); necessary for poly2mask function
x_roi_px = interp1(y_mm, 1:length(y_mm), y_roi_mm);
y_roi_px = interp1(z_mm, 1:length(z_mm), z_roi_mm);
roi_mask = poly2mask(x_roi_px, y_roi_px, size(rgb_img, 1), size(rgb_img, 2));

% Plot only pixels that are part of ROI (to make sure it worked)
figure;
image(y_mm, z_mm, rgb_img.*repmat(roi_mask, [1 1 3]));
axis equal tight xy
xlabel('Y (mm)');
ylabel('Z (mm)');
title('Image colored by empirical dye dilution (lesion only)');

1;
