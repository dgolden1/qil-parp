function paper_print(filename, str_fig_size, scalefactor, paper_path, varargin)
% paper_print(filename, str_fig_size, scalefactor, paper_path, post_process_cfn)
% Print figure for a paper
% 
% JGR Figure Requirements (http://www.agu.org/pubs/authors/manuscript_tools/journals/faq_figure.shtml#d01)
% Full figures: 16.9 cm wide
% Half figures: 8.4 cm wide
% Height not to exceed 23.7 cm
% 
% INPUTS
% filename: output filename (without extension)
% str_fig_size:
%  if str_fig_size is 'half' or empty, will print to half size specification
%  if str_fig_size is 'full', will print to full size specification
%  if str_fig_size is a floating point number, it's the figure width in cm
% scalefactor: scale everything up by this factor (default=3)
% paper_path: output path for figure
% 
% PARAMETERS
% post_process_fcn: function handle which takes the figure handle as an
%  argument.  This function is run after all the figure and font scaling is
%  done.  This is useful to, e.g., make a change to one of the x-axis
%  labels, which may change during figure and font scaling.
% upsample_small_bitmaps: in some PDF viewers, bitmaps are interpolated, so bitmaps with
%  only a few pixels will appear smoothed and really crappy. Set this to true to upsample
%  the images prior to saving (default: false)


% $Id: paper_print.m 282 2013-05-28 23:24:42Z dgolden $

%% Process input args
p = inputParser;
p.addParamValue('post_process_fcn', []);
p.addParamValue('upsample_small_bitmaps', false);
p.parse(varargin{:});

%% Setup
if ~exist('str_fig_size', 'var') || isempty(str_fig_size)
	str_fig_size = 'half';
end
if ~exist('scalefactor', 'var') || isempty(scalefactor)
	scalefactor = 3;
end
if ~exist('b_testrun', 'var') || isempty(b_testrun)
	b_testrun = false;
end

PAPER_PATH = paper_path;

FONTSIZE = 9.7*scalefactor; % Good for 12-pt font in JGR papers
% FONTSIZE = 12.2*scalefactor; % Good for 15-pt font in the thesis
% FONTNAME = 'Arial';
FONTNAME = 'Times New Roman';

%% Font stuff
increase_font(gcf, FONTSIZE, FONTNAME);

% set(gcf, 'paperorientation', 'portrait');

%% Increase line widths
% set(findall(gcf, 'linewidth', 0.5), 'linewidth', 0.5*scalefactor);
h = findall(gcf, '-property', 'linewidth');
for kk = 1:length(h)
  set(h(kk), 'linewidth', get(h(kk), 'linewidth')*scalefactor);
end

%% Set paperposition to the same proportions as position
if isfloat(str_fig_size)
	fig_width_cm = str_fig_size;
elseif strcmp(str_fig_size, 'half')
	fig_width_cm = 8.4;
elseif strcmp(str_fig_size, 'full')
	fig_width_cm = 16.9;
end

set(gcf, 'units', 'centimeters');
set(gcf, 'paperunits', 'centimeters');
pos = get(gcf, 'position');
pp = get(gcf, 'paperposition');

zoom = fig_width_cm/pos(3)*scalefactor;

if pos(4)*zoom/scalefactor > 23.7
	warning('Height %0.2f cm exceeds 23.7 cm', pos(4)*zoom/scalefactor);
end

set(gcf, 'paperposition', [0 0 pos(3) pos(4)]*zoom); % Change proportions and remove margins
set(gcf, 'papersize', pos(3:4)*zoom); % Tight edges
set(gcf, 'position', [pos(1:2) pos(3:4)*zoom]);

if b_testrun
	return;
end

%% Upsample small bitmaps
if p.Results.upsample_small_bitmaps
  min_pixels = 50;
  h_img = findobj(gcf, 'type', 'image');
  for kk = 1:length(h_img)
    if strcmp(get(h_img(kk), 'Tag'), 'TMW_COLORBAR')
      continue;
    end
    cdata = get(h_img(kk), 'CData');
    xdata = get(h_img(kk), 'XData');
    ydata = get(h_img(kk), 'YData');
    xvals = linspace(xdata(1), xdata(end), size(cdata, 2));
    yvals = linspace(ydata(1), ydata(end), size(cdata, 1));
    
    scale_factor = ceil(min_pixels/min(size(cdata)));
    [cdata_resized, xvals_resized, yvals_resized] = resize_image_and_coords(cdata, xvals, yvals, scale_factor, 'imresize_method', 'nearest');
    xdata_resized = xvals_resized([1 end]);
    ydata_resized = yvals_resized([1 end]);
    set(h_img(kk), 'CData', cdata_resized, 'XData', xdata_resized, 'YData', ydata_resized);
  end
end

%% Run post-process function, if given
if ~isempty(p.Results.post_process_fcn)
  p.Results.post_process_fcn(gcf);
end

%% Print
% print('-dpng', '-r75', fullfile(PAPER_PATH, filename));
% fprintf('Wrote %s.png\n', fullfile(PAPER_PATH, filename));

% print('-dpdf', fullfile(PAPER_PATH, filename));

set(gcf, 'color', 'none');
export_fig(fullfile(PAPER_PATH, filename), '-pdf');
set(gcf, 'color', [.8 .8 .8]);
fprintf('Wrote %s.pdf\n', fullfile(PAPER_PATH, filename));

% plot2svg(fullfile(PAPER_PATH, [filename '.svg']));
% fprintf('Wrote %s\n', fullfile(PAPER_PATH, [filename '.svg']));
