% function test_glcm_maps
% Make a GLCM map of an image to detect different regions

% By Daniel Golden (dgolden1 at stanford dot edu) March 2013
% $Id: test_glcm_maps.m 206 2013-03-02 01:38:36Z dgolden $

%% Setup
close all;
clear;

%% Plot original image
img_original = imadjust(imread('pout.tif'));
% img_original = imresize(img_original, 0.5);
figure;
imshow(img_original);

%% Get GLCM from tiles
img = double(img_original);

IF = ImageFeature(img, '', '');
IF.MyROI = ROI([], [], 1:size(img, 2), 1:size(img, 1));

row = 1:size(img, 1);
col = 1:size(img, 2);
[Col, Row] = meshgrid(col, row);

tilesize = [10 10];

if ~all(mod(tilesize, 2) == 0)
  error('Must use even tile size');
end

map_contrast = nan(size(img));

num_cols = ceil(size(img, 2)/tilesize(2)*2);
num_rows = ceil(size(img, 1)/tilesize(1)*2);

figure;

tilecenter = [0.5 0.5];
row_num = 0;
col_num = 0;
while tilecenter(1) <= size(img, 1)
  t_row_start = now;
  row_num = row_num + 1;
  col_num = 0;
  
  idx_row = abs(Row - tilecenter(1)) <= tilesize(1)/2;
  while tilecenter(2) <= size(img, 2)
    col_num = col_num + 1;
    
    idx_col = abs(Col - tilecenter(2)) <= tilesize(2)/2;
    
    tilemask = false(size(img));
    tilemask(idx_row & idx_col) = true;
    
    IF.MyROI.ROIMask = tilemask;
    fs = GetFeatureGLCM(IF);
    
    old_vals = map_contrast(tilemask);
    new_vals = repmat(fs.GetValuesByFeature('glcm_contrast'), [sum(tilemask(:)), 1]);
    map_contrast(tilemask) = nanmean([old_vals, new_vals], 2);
    
    tilecenter(2) = tilecenter(2) + tilesize(2)/2;
    
%     clf;
%     imagesc(tilemask);
%     axis equal tight off;
%     drawnow;
    
    1;
  end
  
  tilecenter(2) = 1;
  tilecenter(1) = tilecenter(1) + tilesize(1)/2;
  
  
  clf;
  imagesc(map_contrast);  
  axis equal tight off;
  title(sprintf('Row %d of %d', row_num, num_rows));
  drawnow;
  
  fprintf('Processed row %d of %d in %s\n', row_num, num_rows, time_elapsed(t_row_start, now));
end

%% Show both
figure;
imshowpair(img, map_contrast, 'montage');

1;