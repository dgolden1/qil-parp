function varargout = log_colorbar(cax, varargin)
% Make a colorbar (in its own figure) with a log scale
% all values should be given in actual units (not log units)
% 
% h_cax = log_colorbar(cax, varargin)
% 
% INPUTS
% cax: two element vector of upper and lower color limits (on a linear
%  scale)
% 
% PARAMETERS
% ax_label: axis label
% cmap: colormap (default: jet)
% orientation: one of 'vertical' (default) or 'horizontal'
% b_log: true (default) for a logarithmic scale; false for a linear scale
% cax_ticks: colorbar tick values
% h_cbar: pre-existing axis onto which the new colorbar will be overlaid
% 
% OUTPUTS
% The two axes handles

% By Daniel Golden (dgolden1 at stanford dot edu) November 2011
% $Id: log_colorbar.m 34 2012-09-05 23:34:19Z dgolden $

%% Setup
% ax_label, orientation, b_log, cax_ticks, cmap
p = inputParser;
p.addParamValue('ax_label', '');
p.addParamValue('cmap', jet(64));
p.addParamValue('orientation', 'vertical');
p.addParamValue('b_log', true);
p.addParamValue('cax_ticks', []);
p.addParamValue('h_cbar', []);
p.parse(varargin{:});

ax_label = p.Results.ax_label;
cmap = p.Results.cmap;
orientation = p.Results.orientation;
b_log = p.Results.b_log;
cax_ticks = p.Results.cax_ticks;
h_cbar = p.Results.h_cbar;

%% Create color axes
old_ax = gca;
if isempty(h_cbar)
  figure;
  ax_color = gca;
else
  % Put a new axes in the same position as the current colorbar
  pos = get(h_cbar, 'position');
  set(h_cbar, 'visible', 'off');
  ax_color = axes('position', pos);
end

if strcmp(orientation, 'horizontal')
  image(1:size(cmap, 1), 1, permute(cmap, [3 1 2]));
else
  image(1, 1:size(cmap, 1), permute(flipud(cmap), [1 3 2]));
end

hold on;
axis(ax_color, 'off');
pos = get(ax_color, 'position');

if isempty(h_cbar)
  % Smush the axes to look more like a strip
  if strcmp(orientation, 'horizontal')
    squish_factor = 8;
    pos = [pos(1), pos(2) + pos(4)*(1 - 1/squish_factor), pos(3), pos(4)/squish_factor];
    set(ax_color, 'position', pos);
  else
    squish_factor = 12;
    pos = [pos(1), pos(2), pos(3)/squish_factor, pos(4)];
    set(ax_color, 'position', pos);
  end
end

%% Create scale axes
ax_scale = axes('position', pos);
set(ax_scale, 'color', 'none');

if strcmp(orientation, 'horizontal')
  xlim(cax);
  xlabel(ax_label);
  set(ax_scale, 'ytick', []);
  if b_log
    set(ax_scale, 'xscale', 'log');
  end
  if ~isempty(cax_ticks)
    set(ax_scale, 'xtick', cax_ticks);
  end
else
  ylim(cax);
  ylabel(ax_label);
  set(ax_scale, 'yaxislocation', 'right', 'xtick', []);
  if b_log
    set(ax_scale, 'yscale', 'log');
  end
  if ~isempty(cax_ticks)
    set(ax_scale, 'ytick', cax_ticks);
  end
end

% Increase tick length
set(ax_scale, 'ticklength', get(ax_scale, 'ticklength')*3);

box on;

%% Set GCA back to what it was unless this colorbar is in a new axes
if ~isempty(h_cbar)
  saxes(old_ax);
end

%% Output arguments
if nargout > 0
  varargout{1} = ax_scale;
  varargout{2} = ax_color;
end
