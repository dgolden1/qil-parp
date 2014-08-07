function h = plot_cost_curve(lines, x_cc, y_cc, h_ax)
% Plot ROC cost curve
% 
% x_cc and y_cc are optional

% By Daniel Golden (dgolden1 at stanford dot edu)
% $id$

%% Setup
if exist('h_ax', 'var') && ~isempty(h_ax)
  saxes(h_ax);
else
  figure;
end

intercepts = [lines.intercept];
slopes = [lines.slope];

%% Plot
% Plot lines
num_lines = length(lines);
x_plot = repmat([0 1].', 1, num_lines);
y_plot = [intercepts; intercepts + slopes];

plot(x_plot, y_plot);
axis([0 1 0 1]);

xlabel('Probability cost function');
ylabel('Normalized expected cost');

if exist('x_cc', 'var') && ~isempty(x_cc)
  % Plot cost curve
  
  % Find points where y_cc changes slope; these are the vertices of the
  % cost curve
  idx_vertices = find([true; abs(diff(y_cc, 2)) > 1e-4; true]);

  hold on;
  plot(x_cc, y_cc, 'k-', 'linewidth', 2);
  plot(x_cc(idx_vertices), y_cc(idx_vertices), 'ks');
end

% Plot quadrant demarcations (only the bottom quadrant is worth anything)
plot([0 1], [0 1], '-', 'linewidth', 2, 'color', [1 1 1]*0.5);
plot([0 1], [1 0], '-', 'linewidth', 2, 'color', [1 1 1]*0.5);

increase_font;
