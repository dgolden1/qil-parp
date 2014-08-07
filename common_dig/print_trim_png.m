function print_trim_png(filename, size_multiplier, varargin)
% Print a trimmed png
% print_trim_png(filename, size_multiplier, varargin)
% All variables in varargin are passed to print

% By Daniel Golden (dgolden1 at stanford dot edu) June 2012
% $Id: print_trim_png.m 333 2013-07-08 21:50:28Z dgolden $

%% Input arguments
if ~exist('size_multiplier', 'var') || isempty(size_multiplier)
  size_multiplier = 1;
end

%% Set up
print_size = 90*size_multiplier;

[dirname, ~, ext] = fileparts(filename);
if strcmp(ext, '.jpg')
  im_type = '-djpeg90';
else
  im_type = '-dpng';
end

if isempty(dirname)
  filename = fullfile('~/temp', filename);
end

% There's a matlab bug that sets white lines overlaid on images to black; here are two
% possible workarounds
% set(gcf, 'InvertHardCopy', 'off')
old_fig_color = get(gcf, 'color');
set(gcf, 'color', 'w');

%% Save
print(im_type, sprintf('-r%0.0f', print_size), varargin{:}, filename);

% Restore old color
set(gcf, 'color', old_fig_color);

%% Trim via system mogrify function
b_is_color = determine_image_color;

if b_is_color
  % Image is color
  mogrify_args = '-trim';
else
  % Image is grayscale
  % These arguments fix a bug in my version of mogrify (Version: ImageMagick 6.8.0-7
  % 2013-04-04 Q16) where grayscale images got darkened by the mogrify function
  % These arguments are sort-of adapted from the advice here:
  % http://www.imagemagick.org/discourse-server/viewtopic.php?f=3&t=23092&start=15
  mogrify_args = '-trim -set colorspace RGB -quality 9';
end

mogrify(mogrify_args, filename);

function b_is_color = determine_image_color
% Return true if image is color or has no image objects, false otherwise

h_images = findobj(gcf, 'type', 'image');

if isempty(h_images)
  b_is_color = true;
  return;
end

for kk = 1:length(h_images)
  h_this_image = h_images(kk);
  cdata = get(h_this_image, 'CData');
  cdatamapping = get(h_this_image, 'CDataMapping');
  if size(cdata, 3) > 1 && ~all(flatten(diff(cdata, 1, 3)) == 0) || ... % RGB image and three channels are not all the same
      strcmp(cdatamapping, 'scaled') && ~all(flatten(diff(colormap, 1, 2)) == 0) % imagesc image and the colormap is not gray
    b_is_color = true;
    return;
  end
end

b_is_color = false;