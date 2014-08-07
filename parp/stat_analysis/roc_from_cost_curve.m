function [x_roc, y_roc] = roc_from_cost_curve(x_cc, y_cc, b_plot)
% Get an ROC curve from a cost curve
% See "What ROC Curves Can't Do (and Cost Curves Can)" by Drummont and
% Holte

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

%% Setup
if ~exist('b_plot', 'var') || isempty(b_plot)
  b_plot = false;
end

%% Estimate cost curve lines
vertices = find([true; abs(diff(y_cc, 2)) > 1e-4; true]);

% Find a line between each vertex
for kk = 1:(length(vertices) - 1)
  lines(kk).slope = diff(y_cc(vertices([kk+1, kk])))/diff(x_cc(vertices([kk+1, kk])));
  lines(kk).intercept = y_cc(vertices(kk)) - lines(kk).slope*x_cc(vertices(kk));
end

slopes = [lines.slope];
intercepts = [lines.intercept];

%% Get ROC coordinates from cost curve lines
x_roc = intercepts;
y_roc = 1 - (intercepts + slopes);

if iscolumn(x_cc)
  x_roc = x_roc(:);
  y_roc = y_roc(:);
end

%% Plot
if b_plot
  figure;
  plot(x_roc, y_roc, 'k-', 'linewidth', 2);
  xlabel('1 - Specificity');
  ylabel('Sensitivity');
  grid on
  increase_font;
end
