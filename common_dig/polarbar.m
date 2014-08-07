function varargout = polarbar(varargin)
% h = polarbar(theta, r)
% Plot a polar bar plot

% By Daniel Golden (dgolden1 at stanford dot edu) December 2009
% $Id: polarbar.m 13 2012-08-10 19:30:42Z dgolden $

% PLOT_TYPE = 'line';
PLOT_TYPE = 'patch';

%% Arguments
error(nargchk(2, 2, nargin));
theta = varargin{1};
r = varargin{2};


%% Prepare plot
theta_diff = mod(diff([theta(:); theta(1)]), 2*pi);
theta_edges = mod(theta(:) - theta_diff/2, 2*pi);

theta_plot = zeros(length(theta)*3 + 1, 1);
r_plot = zeros(length(theta)*3 + 1, 1);

theta_plot(2:3:end) = theta_edges;
theta_plot(3:3:end) = [theta_edges(2:end); theta_edges(1)];
theta_plot(4:3:end) = [theta_edges(2:end); theta_edges(1)];

r_plot(2:3:end) = r;
r_plot(3:3:end) = r;
r_plot(4:3:end) = 0;


%% Plot
TTickValue = 0:(pi/4):(7*pi/4);
TTickLabel = {'00', 'Post-midnight', '06', 'Pre-noon', '12', 'Post-noon', '18', 'Pre-midnight'};
% TTickValue = 0:pi/2:3*pi/2;
RMax = ceil(max(r_plot)*20)/20; % Round up to nearest 0.2
RLimit = [0 RMax];
TZeroDirection = 'West';

switch PLOT_TYPE
	case 'line'
		polar(theta_plot, r_plot);
	case 'patch'
		mmpolar(theta_plot, r_plot, 'TTickScale', 'radians', 'TTickValue', TTickValue, ...
			'TTickLabel', TTickLabel, ...
			'RLimit', RLimit, 'TZeroDirection', TZeroDirection);
		hold on;
		% we have to normalize r_plot by RMax to get the appropriate
		% cartesian grid points when using mmpolar
		patch((r_plot/RMax).*cos(theta_plot), (r_plot/RMax).*sin(theta_plot), 'b');
% 		polar(theta_plot, r_plot);
% 		hold on;
% 		patch(r_plot.*cos(theta_plot), r_plot.*sin(theta_plot), 'b');
end
