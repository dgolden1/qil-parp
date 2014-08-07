function slices_registered = register_pre_post(slices, t, img_bounds)
% Register pre-contrast and post-contrast images if the patient has moved
% slices_registered = register_pre_post(slices, t, img_bounds)
% 
% img_bounds can be row and column bounds of a subset of the image to
%  register (i.e., a course area around the lesion);
%  img_bounds = [x_min x_max y_min y_max]

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Setup
if ~exist('img_bounds', 'var') || isempty(img_bounds)
  img_bounds = [1 size(slices, 2) 1 size(slices, 1)];
else
  error('The img_bounds feature doesn''t currently work; don''t use it');
end



%% Select pre and post images
dt = diff(t);

if median(dt) < 15
  % Stanford scan consisting of wash in and wash out sequences
  idx_pre = find(dt > 15, 1, 'first');
  idx_post = idx_pre + 1;
else
  % Non-stanford scan
  idx_pre = 1;
  idx_post = 2;
end

sub_img_pre_contrast = slices(img_bounds(3):img_bounds(4), img_bounds(1):img_bounds(2), idx_pre);
sub_img_post_contrast = slices(img_bounds(3):img_bounds(4), img_bounds(1):img_bounds(2), idx_post);

img_pre_contrast = slices(:,:,idx_pre);
img_post_contrast = slices(:,:,idx_post);

%% Register
[optimizer, metric] = imregconfig('multimodal');
optimizer.GrowthFactor = 1.1;
t_start = now;
[sub_img_post_contrast_registered, tform] = imregister(sub_img_post_contrast, sub_img_pre_contrast, 'affine', optimizer, metric, 'DisplayOptimization', false);

[M, N] = size(img_pre_contrast);
img_post_contrast_registered = imtransform(img_post_contrast, tform, 'XData', [1 N], 'YData', [1 M], 'Size', [M N]);

figure
s(1) = subplot(1, 2, 1);
imshowpair(img_post_contrast, img_pre_contrast);
title('Pre-registration');

s(2) = subplot(1, 2, 2);
imshowpair(img_post_contrast_registered, img_pre_contrast);
title(sprintf('Registered in %s', time_elapsed(t_start, now)));
linkaxes(s);
zoom on;

%% Make registered slices
post_contrast_indices = idx_post:length(t);
slices_registered = slices;
for kk = 1:length(post_contrast_indices)
  this_idx = post_contrast_indices(kk);
  slices_registered(:,:,this_idx) = imtransform(slices(:,:,this_idx), tform, 'XData', [1 N], 'YData', [1 M], 'Size', [M N]);
end

1;
