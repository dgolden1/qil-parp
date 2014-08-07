function BatchPlotKineticCurves(obj, output_dir)
% Plot and save kinetic curves for all patients

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

%% Setup
if ~exist('output_dir', 'var') || isempty(output_dir)
  output_dir = fullfile(obj.Dirname, 'kinetic_curves');
end

if ~exist('output_dir', 'dir')
  mkdir(output_dir);
end

%% Run
figure;
figure_grow(gcf, 1.7, 0.9);

BatchFun(obj, @(x) plot_and_save(x, output_dir, gcf));

function plot_and_save(obj, output_dir, h_fig)
%% Plot and save a single curve

PlotAverageKineticCurve(obj, 'h_fig', h_fig);

output_filename = fullfile(output_dir, sprintf('parp_%s_kinetic_curve.png', obj.PatientIDStr));
print_trim_png(output_filename);

1;
