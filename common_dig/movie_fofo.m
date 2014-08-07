function movie_fofo(plot_fcn, numframes, varargin)
% movie_fofo(plot_fcn, numframes, param, value, ...)
% Make a high-quality movie using ffmpeg the way Forrest taught me
% 
% INPUTS
% plot_fcn: a function handle and should take one argument: the frame
%  number; the remaining arguments should be explicitly passed into the
%  anonymous function, as movie_fofo(plot_fcn(@(kk) plot_fcn(kk, imgdata),
%  numframes, ...) where imgdata is a NxMxL array of L NxM images or
%  something
% numframes: total number of frames in the movie
% 
% PARAMETERS
% frame_dir: output directory for frames (default: /tmp/frames).  All jpegs
%  will be deleted from frame_dir.
% output_filename: output filename (default: ~/temp/movie.avi)
% framerate: frames per second (default: 15)
% b_use_existing_frames: if true, existing frames will be used from
%  frame_dir (in case you made the frames already and just want to tweak
%  something about the movie, e.g., the frame rate) (default: false)
% b_antialias: true to antialias frames by shrinking and then enlarging
%  them (default: false)
% h_fig: if supplied, use a pre-existing figure; otherwise, a new figure
%  will be created

% By Daniel Golden (dgolden1 at stanford dot edu) December 2010
% $Id: movie_fofo.m 329 2013-07-05 19:03:46Z dgolden $

%% Setup
p = inputParser;
p.addParamValue('frame_dir', '/tmp/frames');
p.addParamValue('output_filename', '~/temp/movie.avi');
p.addParamValue('framerate', 15); % Frames/sec
p.addParamValue('b_use_existing_frames', false);
p.addParamValue('b_antialias', false);
p.addParamValue('b_convert_to_h264', false);
p.addParamValue('h_fig', []);
p.parse(varargin{:});
frame_dir = p.Results.frame_dir;
output_filename = p.Results.output_filename;
framerate = p.Results.framerate;
b_use_existing_frames = p.Results.b_use_existing_frames;
b_antialias = p.Results.b_antialias;
h_fig = p.Results.h_fig;

DYLD_prefix = 'DYLD_LIBRARY_PATH="";'; % Fixes a bug in Matlab implementation of libfreetype.6.dylib

[~, ~, output_filename_ext] = fileparts(output_filename);
if ~strcmp(output_filename_ext, '.avi')
  error('Output filename extension must be .avi');
end

%% Run
t_net_start = now;

if ~b_use_existing_frames
  if ~exist(frame_dir, 'dir')
    mkdir(frame_dir);
  else
    if length(dir(frame_dir)) > 2
      cmd = sprintf('rm %s', fullfile(frame_dir, '*.jpg'));
      fprintf('%s\n', cmd);
      unix(cmd);
    end
  end

  if ~isempty(h_fig)
    sfigure(h_fig);
  else
    h_fig = figure;
  end

  for kk = 1:numframes
    t_start = now;
    
    plot_fcn(kk);
    frame_filename = fullfile(frame_dir, sprintf('frame%05d.jpg', kk));
    print(h_fig, '-djpeg95', '-r90', frame_filename);
    mogrify('-trim', frame_filename);
    if b_antialias
      mogrify('-density 2 -resample 1', frame_filename);
    end
    
    fprintf('Wrote %s (%d of %d) in %s\n', frame_filename, kk, numframes, time_elapsed(t_start, now));
  end
end

% ffmpeg flags:
% -y  -- overwrite output files
% -intra -- use only intra frames (disable "motion estimation")
% -r -- frame rate (fps)
% -qscale -- constant quality (1 is probably the best)
% -i -- input files
% -vcodec -- video codec (mjpeg is meant for jpeg inputs)
ffmpeg_path = '/opt/local/bin/ffmpeg'; % OS X 10.7
cmd = sprintf('%s%s -y -intra -r %d -qscale 1 -i %s/frame%%05d.jpg -vcodec mjpeg %s', ...
  DYLD_prefix, ffmpeg_path, framerate, frame_dir, fullfile(output_filename));
fprintf('%s\n', cmd);
[status, result] = unix(cmd);
if status ~= 0
  fprintf('\n');
  warning('Matlab attempt to call ffmpeg failed; do it yourself from the terminal\n%s', result);
end

if p.Results.b_convert_to_h264 && status == 0
  cmd = sprintf('ffmpeg -i %s  -vcodec h264 -y -qscale 10 %s', output_filename, output_filename);
  fprintf('%s\n', cmd);
  [status, result] = unix(cmd);
  
  if status ~= 0
    fprintf('\n');
    warning('%s', result);
  end
end

fprintf('Movie %s created in %s\n', output_filename, time_elapsed(t_net_start, now));
