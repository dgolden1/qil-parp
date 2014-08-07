function generate_simulated_lesion
% Make a fake lesion with known GLCM parameters, in order to test GLCM
% procedure

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012

%% Setup
close all;
rng(0); % Seed random number generator for reproducable results

%% Choose image/ROI parameters
res_full = 1; % mm/pixel
img_size_full = [300 300];
x_coord_mm = ((1:img_size_full(1)) - img_size_full(1)/2)*res_full;
y_coord_mm = x_coord_mm;

%% Pick ROI
% Some coordinates I picked arbitrarily
roi_poly.img_x_mm = [-12.1596  -15.5340  -16.9303  -17.0467  -12.9741   -8.9015   -6.3416   -6.1089   -8.0870]*3 + randn(1,9)*2;
roi_poly.img_y_mm = [-13.2156  -11.7390   -8.0475   -2.1411    0.0738   -1.9934   -4.3560   -8.9335  -13.5110]*3 + randn(1,9)*2;

[x_roi_px, y_roi_px] = roi_mm_to_px(x_coord_mm, y_coord_mm, roi_poly.img_x_mm, roi_poly.img_y_mm);
roi_mask = poly2mask(x_roi_px, y_roi_px, img_size_full(1), img_size_full(2));

%% Generate random image
img = randn(img_size_full);
kernel = ones(5);
img = imfilter(img, kernel); % Smooth the filter so the inter-pixel correlation is higher
img = img - min(img(:)) + 0.1 ; % Make all values positive and above a threshold
img(~roi_mask) = nan;

%% Get GLCM properties of original image
glcm_props_original = get_glcm_properties(img);

%% Resize image and get GLCM properties of new image
scale_factor_range = 5;
scale_factor_vec = logspace(-log10(scale_factor_range), log10(scale_factor_range), 11);

fn = fieldnames(glcm_props_original);
for kk = 1:length(scale_factor_vec)
  scale_factor = scale_factor_vec(kk);
  [glcm_props_resized, img_resized] = resize_lesion_and_get_props(img(roi_mask), roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor);
  
  for jj = 1:length(fn)
    glcm_errors(kk).(fn{jj}) = (glcm_props_resized.(fn{jj}) - glcm_props_original.(fn{jj}))/glcm_props_original.(fn{jj});
    % fprintf('%s error: %g\n', fn{jj}, glcm_errors.(lower(fn{jj})));
  end
end

%% Plot errors as a function of scale factor
figure;
for kk = 1:4
  subplot(2, 2, kk);
  semilogx(scale_factor_vec, [glcm_errors.(fn{kk})], scale_factor_vec, zeros(size(scale_factor_vec)));
  grid on;
  ylabel(fn{kk});
  ylim([-1 1]);
  
  if kk >= 3
    xlabel('Scale Factor');
  end
  increase_font;
end

% scale_factor = 1/0.8;
% [img_resized, roi_mask_resized, x_coord_mm_resized, y_coord_mm_resized] = resize_img_and_roi(img(roi_mask), roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor, true);
% assert(all(isfinite(img_resized(roi_mask_resized))));

% [glcm_props_resized, glcm_resized] = get_lesion_glcm_properties(x_coord_mm_resized, y_coord_mm_resized, 0, roi_mask_resized, roi_poly, {img_resized(roi_mask_resized)}, {'random_map'});

%% Resize image back to original dimensions to see how it got messed up
% img_resized_2 = resize_img_and_roi(img_resized(roi_mask_resized), roi_poly, roi_mask_resized, x_coord_mm_resized, y_coord_mm_resized, 1/scale_factor, true);

%% Plot images before and after resizing
% figure;
% 
% hspace = 0.05;
% vspace = 0.05;
% hmargin = [0.05 0];
% vmargin = [0.05 0];
% 
% s(1) = super_subplot(2, 3, 1, hspace, vspace, hmargin, vmargin);
% imagesc(x_coord_mm, y_coord_mm, img);
% axis equal tight
% cax = caxis;
% 
% s(2) = super_subplot(2, 3, 2, hspace, vspace, hmargin, vmargin);
% imagesc(x_coord_mm_resized, y_coord_mm_resized, img_resized);
% axis equal tight
% caxis(cax);
% 
% s(3) = super_subplot(2, 3, 3, hspace, vspace, hmargin, vmargin);
% imagesc(x_coord_mm, y_coord_mm, img_resized_2);
% axis equal tight
% caxis(cax);
% 
% s(4) = super_subplot(2, 3, 4, hspace, vspace, hmargin, vmargin);
% imagesc(x_coord_mm, y_coord_mm, roi_mask);
% axis equal tight
% 
% s(5) = super_subplot(2, 3, 5, hspace, vspace, hmargin, vmargin);
% imagesc(x_coord_mm_resized, y_coord_mm_resized, roi_mask_resized);
% axis equal tight
% 
% linkaxes(s);
% zoom on;

1;

function [glcm_properties, img_resized] = resize_lesion_and_get_props(img_vals, roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor)

% For debugging
img = nan(size(roi_mask));
img(roi_mask) = img_vals;

% First resize the image in one direction
[img_resized, roi_mask_resized, x_coord_mm_resized, y_coord_mm_resized] = resize_img_and_roi(img_vals, roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor, true);
assert(all(isfinite(img_resized(roi_mask_resized))));

% Then resize it back
img_resized_2 = resize_img_and_roi(img_resized(roi_mask_resized), roi_poly, ...
  roi_mask_resized, x_coord_mm_resized, y_coord_mm_resized, size(roi_mask, 1)/size(roi_mask_resized, 1), true);

[glcm_properties, glcm] = get_glcm_properties(img_resized_2);

% DEBUG PLOT
if false
  figure;
  s(1) = subplot(1, 3, 1);
  imagesc(x_coord_mm, y_coord_mm, img); axis equal tight
  cax = caxis;
  title('Original');
  s(2) = subplot(1, 3, 2);
  imagesc(x_coord_mm, y_coord_mm, img_resized_2); axis equal tight
  title('Reized');
  caxis(cax);
  s(3) = subplot(1, 3, 3);
  imagesc(x_coord_mm, y_coord_mm, abs(img - img_resized_2)); axis equal tight;
  colorbar
  title('Error');
  linkaxes(s);
  zoom on
end
