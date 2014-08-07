function compress_img(ax, down_factor, direction_str)
% Take an image and compress it in either the x or y direction
% 
% INPUTS
% ax: an axis (or figure) handle containing the image
% down_factor: factor by which to downsample the image
% direction_str: either 'y' or 'x'; the direction in which to compress

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id: compress_img.m 13 2012-08-10 19:30:42Z dgolden $

im = findall(ax, 'Type', 'image');

for kk =1:length(im)
	CData = get(im(kk), 'CData');
	switch direction_str
		case 'y'
% 			YData = get(im(kk), 'YData');
% 			set(im, 'CData', CData(1:down_factor:end, :), 'YData', YData(1:down_factor:end));
			set(im, 'CData', CData(1:down_factor:end, :));
			axis tight;
		case 'x'
% 			XData = get(im(kk), 'XData');
% 			set(im, 'CData', CData(:, 1:down_factor:end), 'XData', XData(1:down_factor:end));
			set(im, 'CData', CData(:, 1:down_factor:end));
			axis tight;
	end
end
