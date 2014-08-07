function BatchPlotEmpiricalMaps(obj, output_dir)
% Plot PK maps for each patient and save them somewhere

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

%% Setup
if ~exist('output_dir', 'var') || isempty(output_dir)
  output_dir = fullfile(obj.Dirname, 'maps_empirical');
end
if ~exist(output_dir, 'dir')
  mkdir(output_dir);
end

%% Run
figure;
%figure_grow(gcf, 1, 1.3);

patient_ids = GetPatientList(obj);
for kk = 1:length(patient_ids)
  t_start = now;
  
  clf;
  
  PDMI = GetPatientImage(obj, patient_ids(kk));
  PlotEmpiricalMapHSV(PDMI, 'h_ax', gca);
  increase_font;
  
  output_filename = fullfile(output_dir, sprintf('parp_%s_empirical.png', patient_id_tostr(patient_ids(kk))));
  print_trim_png(output_filename);
  fprintf('Saved %s (%d of %d) in %s\n', output_filename, kk, length(patient_ids), time_elapsed(t_start, now));
end
