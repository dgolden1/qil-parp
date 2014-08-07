function [new_image_data, new_color_map, new_cax] = colormap_white_bg(image_data, color_map, cax)
% [new_image_data, new_color_map, new_cax] = colormap_white_bg(image_data, color_map, cax)
% 
% Screw with the colormap and image data so that the values below
% the lower bound of the color map are white, without messing 
% anything else up
%
% After running this, plot the image with:
% imagesc(new_image_data);
% colormap(new_color_map);
% caxis(new_cax);

% By Daniel Golden (dgolden1 at stanford dot edu) April 2010
% $Id: colormap_white_bg.m 2 2012-08-02 23:59:40Z dgolden $

n = size(color_map, 1);

new_image_data = image_data;
white_value = cax(1) - (cax(2) - cax(1))/n*1.0001;
new_image_data(image_data < cax(1)) = white_value;

new_color_map = [[1,1,1]; color_map];

new_cax = [white_value cax(2)];
