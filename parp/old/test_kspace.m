function test_kspace
% A function to mess around with k-space, since MRI images are acquired in
% k-space

% By Daniel Golden (dgolden1 at stanford dot edu) March 2012
% $Id$

%% Setup
close all;

patient_id = 51;

%% Load data
slice_filename = get_slice_filename(patient_id);
load(slice_filename);
slice = slices(:,:,10);

%% Get fft
slice_fft = fftshift(fft2(slice - mean(slice(:))));

%% Get frequency step
[x_coord_mm, y_coord_mm, x_label, y_label] = get_img_coords(x_mm, y_mm, z_mm);
n = length(x_coord_mm); % number of samples
assert(mod(n, 2) == 0);
dx = diff(x_coord_mm(1:2)); % mm/sample
sample_rate = (1/dx); % samples/mm
dk = sample_rate/n; % 1/mm
k = (-n/2:(n/2-1))/n*sample_rate;
[Kx, Ky] = ndgrid(k, k);

%% Plot
figure;
figure_grow(gcf, 1.5, 1);

subplot(1, 2, 1);
imagesc(x_coord_mm, y_coord_mm, slice);
axis xy equal tight
title('Image');

subplot(1, 2, 2);
imagesc(k, k, db(slice_fft));
axis xy equal tight
title('FFT');
c = colorbar;
ylabel(c, 'dB');

%% Lowpass filter
slice_fft_lowpass = slice_fft;
slice_fft_lowpass(sqrt(Kx.^2 + Ky.^2) > 0.1) = 0;
slice_lowpass = ifft2(ifftshift(slice_fft_lowpass));

figure;
figure_grow(gcf, 1.5, 1);

subplot(1, 2, 1);
imagesc(x_coord_mm, y_coord_mm, slice_lowpass);
axis xy equal tight
title('Image');

subplot(1, 2, 2);
imagesc(k, k, db(slice_fft_lowpass));
axis xy equal tight
title('FFT');
c = colorbar;
ylabel(c, 'dB');


1;
