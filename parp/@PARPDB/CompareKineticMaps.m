function CompareKineticMaps(pdb1, pdb2, varargin)
% Compare per-pixel kinetic maps between patients in two PARPDB objects

% By Daniel Golden (dgolden1 at stanford dot edu) March 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('output_dir', ''); % If not given, plots are not saved
p.addParamValue('db_name1', '');
p.addParamValue('db_name2', '');
p.parse(varargin{:});

if isempty(p.Results.db_name1)
  db_name1 = strrep(pdb1.DirSuffix(2:end), '_', '\_');
else
  db_name1 = p.Results.db_name1;
end

if isempty(p.Results.db_name2)
  db_name2 = strrep(pdb2.DirSuffix(2:end), '_', '\_');
else
  db_name2 = p.Results.db_name2;
end

%% Setup
close all;

%% Get common patients
patient_ids1 = GetPatientList(pdb1);
patient_ids2 = GetPatientList(pdb2);
patient_ids_common = intersect(patient_ids1, patient_ids2);

%% Loop over patients and collect statistics
map_strings = {'Ktrans', 'Kep', 'Ve', 'WashIn', 'WashOut', 'AUC'};

for kk = 1:length(patient_ids_common)
  t_patient_start = now;
  
  PDMI1 = GetPatientImage(pdb1, patient_ids_common(kk));
  PDMI2 = GetPatientImage(pdb2, patient_ids_common(kk));
  
  for jj = 1:length(map_strings)
    IF_name = ['IF' map_strings{jj}];
    IF1 = PDMI1.(IF_name);
    IF2 = PDMI2.(IF_name);
    
    roi_pixels1{kk,jj} = IF1.ROIPixels;
    roi_pixels2{kk,jj} = IF2.ROIPixels;
    
    if ~isequal(size(roi_pixels1{kk,jj}), size(roi_pixels2{kk,jj}))
      error('Number of pixels in rois of patient %s differ', patient_id_tostr(patient_ids_common(kk)));
    end
  end
  
  fprintf('Processed patient %s (%d of %d) in %s\n', patient_id_tostr(patient_ids_common(kk)), kk, length(patient_ids_common), time_elapsed(t_patient_start, now));
end

%% Combine all patients together
roi_pixels_all_patients1 = collapse_first_cell_dim(roi_pixels1);
roi_pixels_all_patients2 = collapse_first_cell_dim(roi_pixels2);


%% Calculate some statistics
pixel_relative_difference = cell2mat(cellfun(@(x,y) log10(abs((x - y)./x)), roi_pixels_all_patients1, roi_pixels_all_patients2, 'uniformoutput', false));
pixel_rms_error = cellfun(@(x,y) sqrt(mean((x - y).^2)), roi_pixels_all_patients1, roi_pixels_all_patients2);
pixel_relative_rms_error = cellfun(@(x,y) sqrt(mean(((x - y)./x).^2)), roi_pixels_all_patients1, roi_pixels_all_patients2);

%% Make bar plots
figure;
bar(pixel_relative_rms_error);

% Make room for rotated tick labels
pos = get(gca, 'position');
axis_shift = 0.1;
set(gca, 'position', [pos(1), pos(2) + axis_shift, pos(3), pos(4) - axis_shift]);

set(gca, 'xtick', 1:length(pixel_relative_rms_error), 'xticklabel', map_strings);
ylabel('Relative RMS Error');
grid on;
rotateticklabel(gca, 45);
increase_font;


figure;
figure_grow(gcf, 2, 1);
for kk = 1:6
  s(kk) = subplot(2, 3, kk);
  hist(pixel_relative_difference(:,kk), 50);
  xlabel(sprintf('%s log. rel. diff. (\\mu=%0.2f, \\sigma=%0.2f)', map_strings{kk}, mean(pixel_relative_difference(:,kk)), std(pixel_relative_difference(:,kk))));
  ylabel('Count');
  grid on;
  xlim([-5 5]);
end
increase_font;

%% Find the three best and worst matches for each kinetic parameter
pixel_rel_diff_per_img = cell2mat(cellfun(@(x,y) mean(log10(abs((x - y)./x))), roi_pixels1, roi_pixels2, 'uniformoutput', false));

h(1) = figure;
h(2) = figure;

for kk = 1:size(pixel_rel_diff_per_img, 2)
  [~, sort_idx] = sort(pixel_rel_diff_per_img(:,kk));
  
  for jj = [1, length(sort_idx)]
    this_idx = sort_idx(jj);
    p1 = GetPatientImage(pdb1, patient_ids_common(this_idx));
    cax = plot_one_map(p1, map_strings{kk}, db_name1, [], p.Results.output_dir, h(1));
    
    p2 = GetPatientImage(pdb2, patient_ids_common(this_idx));
    plot_one_map(p2, map_strings{kk}, db_name2, cax, p.Results.output_dir, h(2));

    fprintf('Patient %s %s relative diff error: %0.2f\n', patient_id_tostr(patient_ids_common(this_idx)), map_strings{kk}, pixel_rel_diff_per_img(this_idx, kk));
  end
end

1;

function cell_array_collapsed = collapse_first_cell_dim(cell_array)
%% Function: collapse the first dimension of cell_array so an NxM struct becomes 1xM

cell_array_mat = cell2mat(cell_array);
cell_array_collapsed = mat2cell(cell_array_mat, size(cell_array_mat, 1), ones(1, size(cell_array_mat, 2)));

function cax = plot_one_map(PDMI, map_string, db_name, cax, output_dir, h_fig)
%% Function: plot a single kinetic map

clf(h_fig);
sfigure(h_fig);

cax = PlotMapOnPostImg(PDMI, ['IF' map_string], 'cax', cax, 'h_ax', gca, 'b_colorbar', true);
title(sprintf('%s patient %s %s', db_name, patient_id_tostr(PDMI.PatientID), map_string));

if ~isempty(output_dir)
  output_filename = fullfile(output_dir, sprintf('parp_%s_patient_%s_%s.png', map_string, patient_id_tostr(PDMI.PatientID), db_name));
  print_trim_png(output_filename);
  fprintf('Saved %s\n', output_filename);
end
