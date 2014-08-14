function mogrify(arguments, img_filename, b_verbose)
% Run the unix mogrify command on an image
% mogrify(arguments, img_filename, b_verbose)
% 
% Arguments are inserted before the image filename
% Tested on Mac OS X 10.7

% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id: mogrify.m 233 2013-04-04 22:44:06Z dgolden $

if ~exist('b_verbose', 'var') || isempty(b_verbose)
  b_verbose = false;
end

if ~exist(img_filename, 'file')
  if exist([img_filename '.png'], 'file')
    img_filename = [img_filename '.png'];
  elseif exist([img_filename '.jpg'], 'file')
    img_filename = [img_filename '.jpg'];
  else
    error('File %s does not exist', img_filename);
  end
end


setup_prefix = 'DYLD_LIBRARY_PATH="";'; % Fixes a bug in Matlab implementation of libfreetype.6.dylib
mogrify_path = get_sys_cmd_path('mogrify');

% Manually-downloaded version of ImageMagick to fix bug relating to png getting darker
% after conversion
% setup_prefix = sprintf('export MAGICK_HOME="%s"; ', fullfile(danmatlabroot, 'ImageMagick-6.8.3'));
% setup_prefix = [setup_prefix 'export PATH="$MAGICK_HOME/bin:$PATH"; '];
% setup_prefix = [setup_prefix 'export DYLD_LIBRARY_PATH="$MAGICK_HOME/lib/"; '];
% mogrify_path = fullfile(danmatlabroot, 'ImageMagick-6.8.3', 'lib', 'ImageMagick-6.8.3', 'bin-Q16', 'mogrify');

img_filename_sanitized = strrep(img_filename, ' ', '\ ');

cmd = sprintf('%s%s %s %s', setup_prefix, mogrify_path, arguments, img_filename_sanitized);

if b_verbose
  fprintf('%s\n', cmd);
end

[status, result] = system(cmd);

if b_verbose || status
  fprintf('%s\n', result);
end
