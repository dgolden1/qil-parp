function kde2d_plot(x, y, n, x_lim, y_lim, h_ax)
% Make a quick plot using kde2d density estimator
% kde2d_plot(x, y, n, x_lim, y_lim, h_ax)

% By Daniel Golden (dgolden1 at stanford dot edu) March 2012
% $Id: kde2d_plot.m 13 2012-08-10 19:30:42Z dgolden $

%% Setup
if ~isvector(x) || ~isvector(y)
  error('x and y must be vectors');
end

data = [x(:) y(:)];

if ~exist('n', 'var') || isempty(n)
  n = 2^8;
end
if ~exist('x_lim', 'var')
  x_lim = [];
  y_lim = [];
end

%% Run kde2d
if ~isempty(x_lim) && ~isempty(y_lim)
  min_xy = [x_lim(1) y_lim(1)];
  max_xy = [x_lim(2) y_lim(2)];
  [bandwidth, density, X, Y] = kde2d(data, n, min_xy, max_xy);
else
  [bandwidth, density, X, Y] = kde2d(data, n);
end

%% Plot
if exist('h_ax', 'var')
  saxes(h_ax);
else
  figure;
end

imagesc(X(1,:), Y(:,1), density);
axis xy;
c = colorbar;
