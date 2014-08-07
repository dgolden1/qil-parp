function forest_plot(low_vals, high_vals, dot_vals, names, varargin)
% forest_plot(low_vals, high_vals, dot_vals, names, x_label)
% 
% Make a forest plot which consists of a bunch of horizontal lines with
% dots in them; each horizontal line is one study, and the line extents and
% dots represent some parameters of that study
% 
% See http://en.wikipedia.org/wiki/Forest_plot
% 
% PARAMETERS
% x_label: the x-axis label (default: '')
% plot_title: the plot title (default: '')
% legend_names: cell array with names for the low value, high value and dot
% low_plot_params: cell array of arguments to plot() function for low marker
%  (default: {'o', 'color', [0 0.5 0], 'markerfacecolor', [0 0.5 0]})
%  Leave blank to not plot low marker
% high_plot_params: cell array of arguments to plot() function for high marker
%  (default: {'rs', 'markerfacecolor', 'r'})
%  Leave blank to not plot high marker
% dot_plot_params: cell array of arguments to plot() function for dot marker
%  (default: {'b^', 'markerfacecolor', 'b', 'markersize', 8})
% junk_idx: a vector the same size as low_vals, set to true for any lines
%  to not plot and instead label as 'junk'
% 
% Some code borrowed from http://www.mathworks.com/matlabcentral/newsreader/view_thread/257587

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id: forest_plot.m 158 2013-01-24 23:41:06Z dgolden $

%% Parse input variables
p = inputParser;
p.addParamValue('x_label', '');
p.addParamValue('plot_title', '');
p.addParamValue('legend_names', []);
p.addParamValue('low_plot_params', {'o', 'color', [0 0.5 0], 'markerfacecolor', [0 0.5 0]});
p.addParamValue('high_plot_params', {'rs', 'markerfacecolor', 'r'});
p.addParamValue('dot_plot_params', {'b^', 'markerfacecolor', 'b', 'markersize', 8});
p.addParamValue('junk_idx', false(size(low_vals)));
p.parse(varargin{:});
x_label = p.Results.x_label;
plot_title = p.Results.plot_title;
legend_names = p.Results.legend_names;
junk_idx = p.Results.junk_idx;

%% Plot
figure;
hold on
t = [];
for kk = 1:length(low_vals)
  if junk_idx(kk)
    t(end+1) = text(0.5, kk, 'junk', 'color', 'r', 'horizontalalignment', 'center');
  else
    plot([low_vals(kk) high_vals(kk)], [kk kk], 'k', 'linewidth', 2);
    
    m = [];
    if ~isempty(p.Results.low_plot_params)
      m(end+1) = plot(low_vals(kk), kk, p.Results.low_plot_params{:});
    end
    if ~isempty(p.Results.high_plot_params)
      m(end+1) = plot(high_vals(kk), kk, p.Results.high_plot_params{:});
    end
    m(end+1) = plot(dot_vals(kk), kk, p.Results.dot_plot_params{:});
    
    % For debugging: write value of dot in big letters
    % text(dot_vals(kk), kk, sprintf('  %0.2f', dot_vals(kk)), 'fontweight', 'bold', ...
    %   'horizontalalignment', 'left', 'verticalalignment', 'middle', 'color', [1 0 1]);
  end
end

xlim([0 1]);
ylim([0, length(low_vals)+1]);

set(gca, 'ytick', 1:length(low_vals));
%set(gca, 'yticklabel', names);

% Make y-tick labels with color
[~, hy] = format_ticks(gca, '', names);

% Right-align the y-tick labels
for kk = 1:length(hy)
  this_extent = get(hy(kk), 'extent');
  right_edge(kk) = this_extent(1) + this_extent(3);
end
right_most_edge = max(right_edge);
for kk = 1:length(hy)
  this_pos = get(hy(kk), 'position');
  set(hy(kk), 'position', [this_pos(1) + right_most_edge - right_edge(kk), this_pos(2:3)]);
end

% Squish main axes to that the y-ticks fit
pos = get(gca, 'position');
move_amt = 0.2;
set(gca, 'position', [pos(1) + move_amt, pos(2), pos(3) - move_amt, pos(4)]);

xlabel(x_label);
title(plot_title);

if ~isempty(legend_names)
  legend(legend_names, 'location', 'eastoutside');
end

grid on;
box on;
increase_font;
