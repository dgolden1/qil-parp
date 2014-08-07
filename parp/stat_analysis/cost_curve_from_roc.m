function [x_cc, y_cc, lines] = cost_curve_from_roc(roc_x, roc_y, b_plot)
% Get a cost curve based on an ROC curve
% 
% See "What ROC curves can't do (and cost curves can)" by Drummond and Hote
% 2004

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

%% Setup
if ~exist('b_plot', 'var') || isempty(b_plot)
  b_plot = false;
end

%% Compute slopes and intercepts for cost curve lines
for kk = 1:length(roc_x)
  lines(kk).intercept = roc_x(kk);
  lines(kk).slope = 1 - roc_y(kk) - roc_x(kk);
end
intercepts = [lines.intercept];
slopes = [lines.slope];

%% Get cost curve points

% Calculate points for predeterimed x-points; this isn't exact, but I don't
% know of a good way to do it otherwise
n = 100;
x_cc = linspace(0, 1, n).';
x_cc_mat = repmat(x_cc, 1, length(roc_x)); % x-points down rows, roc points (lines) across columns
intercepts_mat = repmat(intercepts, length(x_cc), 1);
slopes_mat = repmat(slopes, length(x_cc), 1);
y_cc_mat = intercepts_mat + slopes_mat.*x_cc_mat;
y_cc = min(y_cc_mat, [], 2);

% Find vertices and delete points that are not vertices
% vertices_idx = [true; abs(diff(y_cc, 2)) > 1/(10*n); true];
% x_cc = x_cc(vertices_idx);
% y_cc = y_cc(vertices_idx);

%% Plot
if b_plot
  plot_cost_curve(lines, x_cc, y_cc);
end

1;
