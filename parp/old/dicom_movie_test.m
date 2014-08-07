function dicom_movie_test
% A little function to load up Kyung Sung's test images and play them as a
% movie
% Download test images from https://www.stanford.edu/~kyungs/software/DCE_tool/DCE_Tool.zip

% By Daniel Golden (dgolden1 at stanford dot edu) August 2011
% $Id$

%% Setup
close all;

[~,hostname] = system('hostname');
switch hostname(1:end-1)
  case 'quadcoredan.stanford.edu'
    dicom_dir = '/home/dgolden/temp/DCE_Tool';
  case 'dantop'
    dicom_dir = 'C:\Users\Daniel\temp\test_images';
end
d = dir(fullfile(dicom_dir, '*.dcm'));

%% Load dicom data
for kk = 1:length(d)
  info(kk) = dicominfo(fullfile(dicom_dir, d(kk).name));
  im_stack(:,:,kk) = dicomread(fullfile(dicom_dir, d(kk).name));
end

slice_locations = unique([info.SliceLocation]); % slice_idx location in Z axis (cm?)
trigger_times = unique([info.TriggerTime]); % Time of this image from first image (ms)

assert(size(im_stack, 3) == length(slice_locations)*length(trigger_times));

%% Make a movie
figure;
h_img = imagesc(zeros(size(im_stack(:,:,1))));
axis off tight;
colormap(gray);
caxis([0 quantile(double(flatten(im_stack)), 0.99)]);
colorbar;

slice_idx = 1;
for kk = 1:length(trigger_times)
  idx = [info.SliceLocation] == slice_locations(slice_idx) & [info.TriggerTime] == trigger_times(kk);
%   set(h_img, 'CData', im_stack(:, :, idx));
  set(h_img, 'CData', im_stack(:, :, idx) - im_stack(:, :, slice_idx));
  F(kk) = getframe;
end

h_ax(1) = gca;

% movie(F, 3, 8);

%% Pick range of pixels and plot time series
slice = double(im_stack(:, :, slice_idx:length(slice_locations):end));

% [x,y] = ginput(1);

% % Big area
% x = (83:96);
% y = 135:150;

% % Small area
% x = (85:87);
% y = 139:141;

% Whole area
x = 1:size(slice, 2);
y = 1:size(slice, 1);

[X, Y, Z] = ndgrid(x, y, 1:size(slice, 3));

% hold on;
% plot(X(:), Y(:), 'r.', 'markersize', 12);

t = trigger_times;
ampl = interpn(slice, Y, X, Z);

% Plot time curves of signal amplitude
% figure
% plot(t/1e3/60, reshape(ampl, [size(ampl,1)*size(ampl,2), size(ampl,3)]), '-o');
% grid on;
% xlabel('Time (min)');
% ylabel('Signal amplitude (arbitrary units)');

%% Get curve empirical criteria
% Criteria determined by Hauth et al., 2008, 10.1016/j.ejrad.2007.05.026

t1 = 1e3*60*0.5; % Time of injection, ms
t2 = 1e3*60*1.1; % Time midpoint (where plateau may begin, ms)
t3 = max(trigger_times); % End time (ms)

ampl1 = interpn(1:size(slice, 1), 1:size(slice, 2), trigger_times, slice, X(:,:,1), Y(:,:,1), t1*ones(size(X(:,:,1))));
ampl2 = interpn(1:size(slice, 1), 1:size(slice, 2), trigger_times, slice, X(:,:,1), Y(:,:,1), t2*ones(size(X(:,:,1))));
ampl3 = interpn(1:size(slice, 1), 1:size(slice, 2), trigger_times, slice, X(:,:,1), Y(:,:,1), t3*ones(size(X(:,:,1))));

slope1 = ampl2 - ampl1;
slope2 = ampl3 - ampl2;

%% Color pixels according to curves
idx_noheart = true(size(slice(:,:,1)));
idx_noheart(Y(:,:,1).' < 100) = false;


% HSV color
% Hue: initial slope
% Saturation (0=gray, 1=color): initial value
% Value (0=dark, 1=bright): wash-out slope
V = (slope1 - min(slope1(idx_noheart)))/(max(slope1(idx_noheart)) - min(slope1(idx_noheart)));
% S = (ampl1 - min(ampl1(idx_noheart)))/(max(ampl1(idx_noheart)) - min(ampl1(idx_noheart)));
% S = (ampl2 - min(ampl2(idx_noheart)))/(max(ampl2(idx_noheart)) - min(ampl2(idx_noheart)));
S = ones(size(slope1));
H = (slope2 - min(slope2(idx_noheart)))/(max(slope2(idx_noheart)) - min(slope2(idx_noheart)));

rgb_img = reshape(hsv2rgb([H(:) S(:) V(:)]), size(slope1, 1), size(slope1, 2), 3);
rgb_img = max(min(rgb_img, 1), 0);

h(2) = figure;
image(x, y, rgb_img);
axis tight equal;
title('Image colored by empirical dye dilution curve');
h_ax(2) = gca;

colormap hsv;
colorbar('location', 'eastoutside');

linkaxes(h_ax);
zoom on;

1;
