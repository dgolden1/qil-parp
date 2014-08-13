function make_example_PK_maps
% Make a figure showing example lesion PK modeling and maps

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

%% Setup
close all;
clear;

addpath(fullfile(danmatlabroot, 'parp'));

output_dir = fullfile(dandropboxroot, 'papers', '2012_breast_cancer_heterogeneity_and_rcb', 'images');

%% Load
[slice_filename, roi_filename, pk_filename] = get_slice_filename(19, 'pre');
info = [];
load(slice_filename); load(roi_filename); load(pk_filename);

%% Plot PK
[x_coord_mm, y_coord_mm, x_label, y_label, slice_location_mm, slice_label] = get_img_coords(x_mm, y_mm, z_mm);

bg_idx = 10;

bg_img = slices(:,:,bg_idx);
b_zoom = true;
max_ve = 3;
plot_pk_params(x_coord_mm, y_coord_mm, x_label, y_label, bg_img, roi_mask, ktrans, kep, ve, ...
  'bg_img_name', sprintf('t=%0.0f sec', t(bg_idx)), 'max_ve', max_ve, 'b_zoom', b_zoom);

h_pk = gcf;

%% Pick points to plot time series
% Patient coordinates from empirical map
pts_mm = [-14 44
          -23 54
          -7  37];
num_pts = size(pts_mm, 1);
        
% Plot points on kinetic maps
dot_axes = [findobj(0, 'tag', 'im_mapped');
            findobj(0, 'tag', 'im_ktrans');
            findobj(0, 'tag', 'im_kep');
            findobj(0, 'tag', 'im_ve')];
            
co = get(gca, 'colororder');
hold on;
for jj = 1:length(dot_axes)
  saxes(dot_axes(jj));
  hold on;
  
  for kk = 1:num_pts
    plot(pts_mm(kk,1), pts_mm(kk,2), 'o', 'markerfacecolor', co(kk,:), 'markeredgecolor', 'w', 'markersize', 10, 'linewidth', 1);
  end
end

% Image coordinates
pts_img(:,2) = round(interp1(y_coord_mm, 1:length(y_coord_mm), pts_mm(:,2)));
pts_img(:,1) = round(interp1(x_coord_mm, 1:length(x_coord_mm), pts_mm(:,1)));

% Indices into image
idx_img = sub2ind(size(roi_mask), pts_img(:,1), pts_img(:,2));

% Index into ROI mask of these points
for kk = 1:num_pts

  % Use roi_mask_extra instead of roi_mask because the model output is
  % defined over it
  blah = double(roi_mask_extra);
  blah(pts_img(kk,2), pts_img(kk,1)) = 2;
  blah_masked = blah(roi_mask_extra);
  idx_roi(kk) = find(blah_masked == 2);
  
  time_pts_vec(kk,:) = slices(pts_img(kk,2), pts_img(kk,1), :);
  model_vec(kk) = model(idx_roi(kk));
end

h_curves = figure;
hold on

% Plot models and data
for kk = 1:num_pts
  %plot(t, time_pts_vec(kk,:), '-s', 'color', co(kk,:), 'markerfacecolor', 'w');
  plot(model_vec(kk).t_fit, model_vec(kk).enhancement_fit, '--', 'color', co(kk,:), 'linewidth', 2);
  plot(model_vec(kk).t_data, model_vec(kk).enhancement_data, '-s', 'color', co(kk,:), 'markerfacecolor', 'w');
end
plot([1/60 1/60]*t(bg_idx), [0 3], 'k--');
ylim([-1 3]);
grid on;
box on;
xlabel('Minutes');
ylabel('Fractional enhancement');

% Make a fake legend with black lines
h(1) = plot(0, 0, 'k-s', 'markerfacecolor', 'w');
h(2) = plot(0, 0, 'k--', 'linewidth', 2);
legend(h, {'Data', 'PK Model'}, 'location', 'southeast');

figure_grow(gcf, 1.8, 1);

%% Print figures
figure(h_pk);
paper_print('raw_example_pk_maps', 12, 2, output_dir);

figure(h_curves);
post_process_fcn = @(x) delete(h);
paper_print('raw_example_enhancement_pk_curves', 12, 2, output_dir, post_process_fcn);

1;
