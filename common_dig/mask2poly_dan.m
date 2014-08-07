function [poly_x, poly_y] = mask2poly_dan(mask, varargin)
% Convert from mask to polygon
% 
% if b_outer_radius is true (default), use outer radius (dilation minus original);
%  otherwise, use inner radius (original minus erosion)
% 
% Throws error if multiple disconnected regions exist

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id: mask2poly_dan.m 196 2013-02-22 19:55:05Z dgolden $

%% Parse input arguments
p = inputParser;
p.addParamValue('b_outer_radius', false);
p.addParamValue('b_dans_method', true);
p.addParamValue('b_simplify', true);
p.parse(varargin{:});

%% Setup
conn_comp = bwconncomp(mask);
if conn_comp.NumObjects > 1
  error('Multiple (%d) disconnected objects found in image', conn_comp.NumObjects);
end

if p.Results.b_dans_method
  %% Dan's Method of getting unsimplified poly
  % Get mask of ROI border
  if p.Results.b_outer_radius
    mask_dilated = imdilate(mask, strel('disk', 1));
    mask_edge = mask_dilated - mask;
  else
    mask_eroded = imerode(mask, strel('disk', 1));
    mask_edge = mask - mask_eroded;
  end

  % Determine X and Y values for each edge pixel
  x = 1:size(mask, 2);
  y = 1:size(mask, 1);

  [X, Y] = meshgrid(x, y);

  mask_edge_idx = find(mask_edge(:));
  poly_x_unsorted = X(mask_edge_idx);
  poly_y_unsorted = Y(mask_edge_idx);

  % Sort points in order of minimum distance
  % Repeat as long as any minimum distances are longer than expected
  poly_x_all_pts = poly_x_unsorted;
  poly_y_all_pts = poly_y_unsorted;
  idx_invalid = false;
  while ~isempty(idx_invalid)
    % Sort polygon points for plotting
    [poly_x_all_pts, poly_y_all_pts, min_dist] = sortPointMinDist(poly_x_all_pts, poly_y_all_pts);

    % Sometimes points lie outside the main polygon (at corners) and don't get sorted
    % properly; remove points more than sqrt(2) away from their neighbors
    % Kludge: only consider points the last 5 points of the ROI, or else loops in the
    % middle of the ROI get messed up
    idx_invalid = find(min_dist > 2*sqrt(2)*1.01 & 1:length(min_dist) > length(min_dist) - 5, 1);
    poly_x_all_pts(idx_invalid) = [];
    poly_y_all_pts(idx_invalid) = [];
  end
  
else
  %% mask2poly method for unsimplified poly
  poly = mask2poly(mask, 'Inner', 'MINDIST');
  poly_x_all_pts = poly(:,1);
  poly_y_all_pts = poly(:,2);
end

%% Simplify
if p.Results.b_simplify
  tol = 0.5;
  poly_simplified = dpsimplify([poly_x_all_pts(:), poly_y_all_pts(:)], tol);

  poly_x = poly_simplified(:,1);
  poly_y = poly_simplified(:,2);
else
  poly_x = poly_x_all_pts;
  poly_y = poly_y_all_pts;
end