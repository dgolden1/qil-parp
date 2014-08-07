function plot_aim_roi(dicom_filename, aim_filename, h_fig)
% Plot the ROI from an AIM file on a DICOM image
% plot_aim_roi(dicom_filename, aim_filename)

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Load data
dicom_info = dicominfo(dicom_filename);
img = dicomread(dicom_filename);

if isfield(dicom_info, 'RescaleIntercept')
  rescale_intercept = dicom_info.RescaleIntercept;
else
  rescale_intercept = 0;
end
if isfield(dicom_info, 'RescaleSlope')
  rescale_slope = dicom_info.RescaleSlope;
else
  rescale_slope = 1;
end

img = double(img)*rescale_slope + rescale_intercept;

%% Get ROI
[x, y] = get_roi_from_aim(aim_filename);

%% Plot DICOM image and AIM ROI
if ~exist('h_fig', 'var') || isempty(h_fig)
  figure
  figure_grow(gcf, 1.7, 1);
else
  sfigure(h_fig);
  clf
end

subplot(1, 2, 1);
imagesc(img);
colormap gray;
axis equal tight;
hold on
plot(x([1:end, 1]), y([1:end, 1]), 'r-', 'linewidth', 2);

%% Plot zoom in on ROI
subplot(1, 2, 2);
imagesc(img);
colormap gray;
axis equal tight;
hold on
plot(x([1:end, 1]), y([1:end, 1]), 'rs-', 'linewidth', 2, 'markerfacecolor', 'w', 'markeredgecolor', 'r', 'markersize', 8);

max_dim = max(range(x), range(y));
roi_center = [min(x) + range(x)/2, min(y) + range(y)/2];
axis([roi_center(1) + max_dim*0.6*[-1 1], roi_center(2) + max_dim*0.6*[-1 1]]);
