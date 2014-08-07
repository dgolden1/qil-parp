function [x, y] = GetMaskBoundPixels(obj, b_outer_radius)
% Get pixels that form the boundary of the ROI

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id: GetMaskBoundPixels.m 187 2013-02-14 00:35:07Z dgolden $

%% Setup
if ~exist('b_outer_radius', 'var') || isempty(b_outer_radius)
  b_outer_radius = true;
end

%% Dilate/erode
if b_outer_radius
  mask_dilated = imdilate(obj.ROIMask, strel('disk', 1));
  mask_edge = mask_dilated - obj.ROIMask;
else
  mask_eroded = imerode(obj.ROIMask, strel('disk', 1));
  mask_edge = obj.ROIMask - mask_eroded;
end

%% Find vertices
% Determine X and Y values for each edge pixel
x_idx = 1:size(obj.ROIMask, 2);
y_idx = 1:size(obj.ROIMask, 1);

[X, Y] = meshgrid(x_idx, y_idx);

mask_edge_idx = find(mask_edge(:));
x = X(mask_edge_idx);
y = Y(mask_edge_idx);