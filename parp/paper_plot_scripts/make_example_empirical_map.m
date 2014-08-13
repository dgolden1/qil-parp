function make_example_empirical_map
% Make an example empirical kinetic map and kinetic curve

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

close all;

addpath(fullfile(danmatlabroot, 'parp'));

output_dir = fullfile(dandropboxroot, 'papers', '2012_breast_cancer_heterogeneity_and_rcb', 'images');

%% Load
[slice_filename, roi_filename, pk_filename] = get_slice_filename(19, 'pre');
info = [];
load(slice_filename); load(roi_filename); load(pk_filename);

%% Plot emprical
plot_empirical_kinetic_map(slices, x_mm, y_mm, z_mm, t, info, 'roi_mask', roi_mask, 'b_zoom', true, 'b_color_only_lesion', false)

% Zoom out a little
zoom_frac = 1.5;
ax = axis;
dx = diff(ax([2 1]));
dy = diff(ax([4 3]));
axis([ax(1) - dx/2*(1 - zoom_frac), ax(2) + dx/2*(1 - zoom_frac), ax(3) - dy/2*(1 - zoom_frac), ax(4) + dy/2*(1 - zoom_frac)]);
axis off;

% Save
%paper_print('raw_example_empirical_map', 8, 2, output_dir);

%% Plot kinetic curve and representative images
[im_mm_x, im_mm_y] = get_img_coords(x_mm, y_mm, z_mm);
[roi_poly_x, roi_poly_y] = mm_to_px(im_mm_x, im_mm_y, roi_poly.img_x_mm, roi_poly.img_y_mm);
roi = ROI(roi_poly_x, roi_poly_y, im_mm_x, im_mm_y);

[t1, t2, t3] = get_empirical_time_points(info, t);
t_points = [t1, t2, t3];

% Plot empirical curve
roi_pixels = reshape(slices(repmat(roi_mask, [1 1 length(t)])), [sum(roi_mask(:)), length(t)]);
avg_signal = mean(roi_pixels);

figure;
figure_grow(gcf, 2, 1);
plot(t/60, avg_signal, 'ks-', 'markerfacecolor', 'w', 'linewidth', 1);
xlabel('Time (minutes)');
ylabel('Avg pixel intensity');
hold on;
plot(t_points/60, interp1(t, avg_signal, t_points), 'ro', 'markerfacecolor', 'w', 'markersize', 12, 'linewidth', 1);
grid on;
increase_font
set(gca, 'xtick', 0:2:max(t/60));
ylim([300 1100]);

paper_print('raw_enhancement_vs_time', 10, 2, output_dir);

% Plot representative images
figure;
figure_grow(gcf, 2, 1);
cax = [0 1.5e3];
for kk = 1:3
  subplot(1, 3, kk);
  imagesc(slices(:,:,interp1(t, 1:length(t), t_points(kk), 'nearest')));
  axis equal;
  colormap gray
  caxis(cax);
  PlotZoomToROI(roi, 1.3);
  axis off;
  title(sprintf('%0.1f min', t_points(kk)/60));
  
  if kk == 1
    PlotDrawLengthMarker(roi);
  end
end
increase_font;

paper_print('raw_enhancement_example_images', 10, 2, output_dir);

1;