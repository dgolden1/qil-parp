function test_registration_sub_img
% Try to register a portion of an image and apply the transform matrix to
% the whole image

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Setup
close all;

%% Make original image
x = (1:100) - 50.5;
y = x;

[X, Y] = meshgrid(x, y);
R = sqrt(X.^2 + Y.^2);

im1 = zeros(size(R));
im1(R > 10 & R < 12) = 1;

%% Make translated image
xform = [0.8 0 0
         0 1.2 0
         20 0 1];
tform = maketform('affine', xform);

im2 = imtransform(im1, tform, 'XData', [1 size(im1, 2)], 'YData', [1 size(im1, 1)]);

%% Plot
figure
s(1) = subplot(1, 2, 1);
imshow(im1, 'initialmagnification', 'fit');
title('Forward');
s(2) = subplot(1, 2, 2);
imshow(im2, 'initialmagnification', 'fit');
linkaxes(s);
zoom on;

%% Make sub-images
crop_x_idx = 30:70;
crop_y_idx = 30:70;

im1_sub = im1(crop_y_idx, crop_x_idx);
im2_sub = im2(crop_y_idx, crop_x_idx);
im2_sub_crop = imtransform(im1_sub, tform, 'XData', [1 size(im2_sub, 2)], 'YData', [1 size(im2_sub, 1)]);

figure
s(1) = subplot(1, 3, 1);
imshow(im1_sub, 'initialmagnification', 'fit');
title('Forward');
s(2) = subplot(1, 3, 2);
imshow(im2_sub, 'initialmagnification', 'fit');
title('Transform then crop');
s(3) = subplot(1, 3, 3);
imshow(im2_sub_crop, 'initialmagnification', 'fit');
title('Crop then transform');
linkaxes(s);
clear s;
zoom on;

%% Align sub-images
tform_inv = fliptform(tform);
% tform_inv = tform;
% tform_inv.tdata.T = tform.tdata.Tinv;
% tform_inv.tdata.Tinv = tform.tdata.T;
% tform_inv.forward_fcn = tform.inverse_fcn;
% tform_inv.inverse_fcn = tform.forward_fcn;

im2_sub_aligned_naive = imtransform(im2_sub, tform_inv, 'XData', [1 size(im2_sub, 2)], 'YData', [1 size(im2_sub, 1)]);
im2_sub_aligned_smart = imtransform(im2_sub, tform_inv, 'XData', crop_x_idx([1 end]), 'YData', crop_y_idx([1 end]), ...
  'UData', crop_x_idx([1 end]), 'VData', crop_y_idx([1 end]), 'XYScale', 1);
im2_sub_crop_aligned = imtransform(im2_sub_crop, tform_inv, 'XData', [1 size(im2_sub, 2)], 'YData', [1 size(im2_sub, 1)]);

figure
figure_grow(gcf, 1.5, 1);
s(1) = subplot(1, 4, 1);
imshow(im1_sub, 'initialmagnification', 'fit');
title('Reverse');
s(2) = subplot(1, 4, 2);
imshow(im2_sub_aligned_naive, 'initialmagnification', 'fit');
title('Transform, crop, inv-transform');
s(3) = subplot(1, 4, 3);
imshow(im2_sub_aligned_smart, 'initialmagnification', 'fit');
title('Transform, crop, smart inv-transform');
s(4) = subplot(1, 4, 4);
imshow(im2_sub_crop_aligned, 'initialmagnification', 'fit');
title('Crop, transform, inv-transform');
linkaxes(s);
clear s;
zoom on;

%% Align full images
im2_aligned = imtransform(im2, tform_inv, 'XData', [1 size(im2, 2)], 'YData', [1 size(im2, 1)]);

figure
s(1) = subplot(1, 2, 1);
imshow(im1, 'initialmagnification', 'fit');
title('Reverse');
s(2) = subplot(1, 2, 2);
imshow(im2_aligned, 'initialmagnification', 'fit');
linkaxes(s);
zoom on;

1;
