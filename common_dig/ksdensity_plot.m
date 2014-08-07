function ksdensity_plot(x, h_ax, varargin)
% Make a quick plot via ksdensity
% ksdensity_plot(x, h_ax, varargin)

% By Daniel Golden (dgolden1 at stanford dot edu) June 2012
% $Id: ksdensity_plot.m 13 2012-08-10 19:30:42Z dgolden $

[f, xi] = ksdensity(x, varargin{:});

if exist('h_ax') && ~isempty(h_ax)
  saxes(h_ax);
else
  figure;
end

plot(xi, f, 'linewidth', 2);
grid on;
ylabel('PDF');
