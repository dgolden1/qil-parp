function MakeInterpolatedMovie(obj, output_dir)
% Make a movie by interpolating image stack across time both for empirical and PK
% modeled pixel values

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

%% Setup
close all

%% Create interpolated data
dt = 10;
t_interp = 0:dt:max(obj.Time);

roi_mask = obj.MyROI.ROIMask;

base_image = obj.ImageStack(:,:,1);
base_enhancement = base_image(roi_mask);
[enhancement_data, t_data, enhancement_fit, t_fit] = reformat_pk_model(obj.PKModel);

[image_stack_data, signal_data, signal_data_interp] = make_interpolated_image_stack(t_data, t_interp, enhancement_data, base_enhancement, roi_mask);
[image_stack_fit, ~, signal_fit_interp] = make_interpolated_image_stack(t_fit, t_interp, enhancement_fit, base_enhancement, roi_mask);

%% Make movie
h_fig = figure;
figure_grow(gcf, 1.5);
movie_fofo(@(frameno) plot_frame(frameno, image_stack_data, image_stack_fit, mean(signal_data), mean(signal_fit_interp), t_interp, obj), ...
  length(t_interp), 'framerate', 10, 'h_fig', h_fig);

1;

function plot_frame(frameno, image_stack_data, image_stack_fit, avg_signal_data, avg_signal_fit_interp, t_interp, obj)
subplot(4, 2, [1 3 5]);
imagesc(image_stack_data(:,:,frameno));
axis equal off
caxis(quantile(image_stack_data(:), [0.01 0.99]));
title(sprintf('Data t = %03.0f sec', t_interp(frameno)));
PlotZoomToROI(obj.MyROI);

subplot(4, 2, [2 4 6]);
imagesc(image_stack_fit(:,:,frameno));
axis equal off
caxis(quantile(image_stack_data(:), [0.01 0.99]));
title(sprintf('PK Fit'));
PlotZoomToROI(obj.MyROI);

subplot(4, 2, [7 8]);
plot(obj.Time, avg_signal_data, 'k-s', 'markersize', 6, 'markerfacecolor', 'w');
hold on;
plot(t_interp, avg_signal_fit_interp, 'b--', 'linewidth', 2);

increase_font;

delete(findobj(gcf, 'tag', 'timeline'));
yl = [0 max(avg_signal_data)*1.1]];
ylim(yl);
h = plot([1 1]*t_interp(frameno), yl, 'r--');
set(h, 'tag', 'timeline');


function [image_stack, signal_data, signal_data_interp] = make_interpolated_image_stack(t, t_interp, enhancement_data, base_enhancement, roi_mask)
%% Function: make_interpolated_image_stack
% Make an image stack which is interpolated in time and converted to MRI signal
% intensity from relative enhancement

% Convert from relative enhancement to MRI signal units
% This is the inverse of the formula from compute_MR_enhancement_from_MR_signal()
signal_data = (enhancement_data + 1).*repmat(base_enhancement, [1 length(t)]);

image_stack = nan([size(roi_mask), length(t_interp)]);

signal_data_interp = interp1(t, signal_data.', t_interp).';
image_stack(repmat(roi_mask, [1 1 length(t_interp)])) = signal_data_interp;

function [enhancement_data, t_data, enhancement_fit, t_fit] = reformat_pk_model(pk_model)
%% Function: Reformat PKModel struct to something easier to interpolate

t_fit = pk_model(1).t_fit*60; % Convert from minutes to seconds
t_data = pk_model(1).t_data*60;

enhancement_fit_cell = {pk_model.enhancement_fit};
enhancement_fit = cell2mat(cellfun(@transpose, enhancement_fit_cell, 'UniformOutput', false)).';

enhancement_data_cell = {pk_model.enhancement_data};
enhancement_data = cell2mat(cellfun(@transpose, enhancement_data_cell, 'UniformOutput', false)).';
