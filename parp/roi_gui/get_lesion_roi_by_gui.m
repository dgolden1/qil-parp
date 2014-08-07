function [roi_mask, roi_poly] = get_lesion_roi_by_gui(patient_id, str_pre_or_post_chemo)
% Manually determine a lesion ROI using a polygon

% INPUTS
% slices: an NxMxR matrix of NxM slices of DCE-MRI values, once for each
%  of R time points
% x_mm, y_mm and z_mm: the DICOM coordinates for each slice (mm)
% t: the time of each slices in sec
% info: the DICOM header for each slices
% type: either 'empirical' (default) to color lightness by wash-in slope
% and color by wash-out slope or 'pk' to create a cell array of three maps
% for ktrans, kep and ve, respectively
%
% OUTPUTS
% roi_mask: mask of the same size as slices which is true for pixels within
%  the ROI
% roi_poly: the constituent polynomial vertices of the ROI; x and y are the
%  IMAGE x and y coordinates, not the DICOM x and y coordinates (since the
%  image may not be in the DICOM x-y plane)

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
close all
addpath(fullfile(qilsoftwareroot, 'parp'));

%% Load ROI GUI
roi_gui(patient_id);

%% Make kinetic map
t_map_start = now;

plot_empirical_kinetic_map(slices, x_mm, y_mm, z_mm, t, info, 'contrast_mask', contrast_mask, 'h_ax', h_ax);
fprintf('Plotted kinetic map in %s\n', time_elapsed(t_map_start, now));
title(sprintf('Emperical kinetic map  patient %d  %s=%0.1f mm', patient_id, slice_label, slice_location_mm));

% % Plot only pixels that are part of ROI (to make sure it worked)
% figure;
% image(y_mm, z_mm, rgb_img.*repmat(roi_mask, [1 1 3]));
% axis equal tight xy
% xlabel('Y (mm)');
% ylabel('Z (mm)');
% title('Image colored by empirical dye dilution (lesion only)');
