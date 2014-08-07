function subax = add_x_axes(h_ax, x_tick_orig, x_tick_labels, x_axes_labels)
% subax = add_x_axes(h_ax, x_tick_orig, x_tick_labels, x_axes_labels)
% 
% Function to add a bunch of extra x-axes to a plot (e.g., UTC and LT)
% 
% This function messes with the units of things, so it can screw up plot
% sizing
% 
% INPUTS
% h_ax: relevant axes
% x_tick_orig: 1xN vector of desired x-ticks in units of the x-values of
% whatever is currently plotted
% x_tick_labels: MxN cell array of N tick labels for each of M separate x-axes
% x_axes_labels: Mx1 cell array of labels for each axis. '\n' characters are
%  encouraged (the axes don't have much space)

% By Daniel Golden (dgolden1 at stanford dot edu) September 2008
% $Id: add_x_axes.m 13 2012-08-10 19:30:42Z dgolden $

%% Setup
N_AX = size(x_tick_labels, 1); % number of axes

if ~exist('x_axes_labels', 'var') || isempty(x_axes_labels)
  % No labels
  x_axes_labels = repmat({''}, 1, N_AX);
elseif N_AX ~= length(x_axes_labels)
	error('x_axes_labels must have as many entries as axes_vec has rows (%d ~= %d)', ...
		N_AX, length(x_axes_labels));
end

% AX_SHF = 0.05; % amount to shift up the original axis, per sub-axis
AX_SHF = 0.1; % amount to shift up the original axis, per sub-axis
XLIM = get(h_ax, 'xlim');

%% Move the original axis up a little to make room for the new x axes
pos_orig = get(h_ax, 'Position');
set(h_ax, ...
    'Position', [pos_orig(1), pos_orig(2) + AX_SHF*N_AX, pos_orig(3), pos_orig(4) - AX_SHF*N_AX]);
pos_orig = get(h_ax, 'Position');

%% Destroy the original x ticks labels
set(h_ax, 'xtick', x_tick_orig, 'XTickLabel', '', 'tickdir', 'out');

%% Create individual smushed subplots for each new x-axes
for kk = 1:N_AX
	subax(kk) = subplot('Position', [pos_orig(1), pos_orig(2)-AX_SHF*kk pos_orig(3), 1e-4]);
	set(subax(kk), 'xlim', XLIM, 'xtick', x_tick_orig, 'xticklabel', x_tick_labels(kk,:), 'ticklength', [0 0]);
	set(get(subax(kk), 'ylabel'), 'String', x_axes_labels{kk});
end

% Overlap the bottom of the main axis with the first subaxis
subpos1 = get(subax(1), 'position');
pos = get(h_ax, 'position');
set(h_ax, 'position', [pos(1) subpos1(2) pos(3) pos(4) + (pos(2) - subpos1(2))]);
