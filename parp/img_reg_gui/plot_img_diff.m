function plot_img_diff(im1, im2, title_str, PDMI, h_ax)
% Plot the registration of two images using imshowpair

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

% Remove artifacts
im1_lim = quantile(im1(:), [0.001 0.999]);
im2_lim = quantile(im2(:), [0.001 0.999]);
im1 = max(min(im1, im1_lim(2)), im1_lim(1));
im2 = max(min(im2, im2_lim(2)), im2_lim(1));

% Plot images
saxes(h_ax);
cla(h_ax, 'reset');
imshowpair(im1, im2);
%zoom(h_ax, 'on');
title(title_str);

% Plot lesion center
[x_center_px, y_center_px] = mm_to_px(PDMI.XCoordmm, PDMI.YCoordmm, PDMI.LesionCenter(1), PDMI.LesionCenter(2));
hold on;
plot(x_center_px, y_center_px, 'ro', 'markerfacecolor', 'w', 'markersize', 8);
