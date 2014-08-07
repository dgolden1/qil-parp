function x_rgb = mat2rgb(x_mat, cmap, cax)
% x_rgb = mat2rgb(x_mat, cmap)
% Function to convert a scaled image to an RGB image using a specified
% colormap

% By Daniel Golden (dgolden1 at stanford dot edu) June 2009
% $Id: mat2rgb.m 136 2012-12-20 23:39:03Z dgolden $

%% Setup
if ~exist('cmap', 'var') || isempty(cmap)
	cmap = jet;
end
if ~exist('cax', 'var') || isempty(cax)
  cax = quantile(x_mat(:), [0 1]);
end

n = size(cmap, 1);

%% Clip
x_mat(x_mat < cax(1)) = cax(1);
x_mat(x_mat > cax(2)) = cax(2);

%% Convert
x_rgb = ind2rgb(gray2ind(mat2gray(x_mat), n), cmap);
