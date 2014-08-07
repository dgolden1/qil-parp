function DebugCheckGLCMPropsAgainstOldStyle(obj, other_pdb)
% Check to ensure that the GLCM properties generated with the 1.5 mm common-resolution
% pre-chemo PARPDB are basically the same as the ones I generated with my old-style
% functions

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

%% Setup
close all;
addpath(fullfile(qilsoftwareroot, 'parp'));
output_dir = '~/temp/prop_test';

%% Get features from PARPDB
this_fs = CollectFeatures(obj, 'b_glcm', true);
assert(issorted(this_fs.PatientIDs));

%% Get old-style features
if ~exist('other_pdb', 'var')
  other_pdb = [];
end

if isempty(other_pdb)
  glcm_struct = [];
  load('lesion_parameters_pre', 'glcm_struct');
  glcm_struct = rmfield(glcm_struct, 'rcb_val');
  assert(issorted([glcm_struct.patient_id]));
  
  other_fs = FeatureSet(glcm_struct);
else
  other_fs = CollectFeatures(other_pdb, 'b_glcm', true);
end

%% Get common patients
patient_ids_common = intersect(this_fs.PatientIDs, other_fs.PatientIDs);

ids_to_remove = this_fs.PatientIDs(~ismember(this_fs.PatientIDs, patient_ids_common));
this_fs = RemovePatients(this_fs, ids_to_remove);

ids_to_remove = other_fs.PatientIDs(~ismember(other_fs.PatientIDs, patient_ids_common));
other_fs = RemovePatients(other_fs, ids_to_remove);

assert(isequal(this_fs.PatientIDs, other_fs.PatientIDs));

%% Set equivalent feature names
this_feature_names = this_fs.FeatureNames;
this_feature_names_cleaned = clean_feature_names(this_feature_names);
other_feature_names = other_fs.FeatureNames;
other_feature_names_cleaned = clean_feature_names(other_feature_names);
  
%% Make plots
if isempty(other_pdb)
  other_fs_name = 'glcm_struct';
else
  other_fs_name = just_filename(other_pdb.Dirname);
end
this_fs_name = just_filename(obj.Dirname);

b_rank = false;

if ~exist(output_dir, 'dir')
  mkdir(output_dir);
end

figure;
figure_grow(gcf, 1.2);
for kk = 1:length(this_feature_names)
% for kk = 8
  other_feature_name = other_feature_names{strcmp(other_feature_names_cleaned, this_feature_names_cleaned{kk})};
  other_data = GetValues(other_fs, [], other_feature_name);
  this_data = GetValues(this_fs, [], this_feature_names{kk});
  
  clf;
  
  if b_rank
    % Assign a rank to each data point
    [~, other_idx] = sort(other_data);
    other_idx(other_idx) = 1:length(other_data);
    [~, this_idx] = sort(this_data);
    this_idx(this_idx) = 1:length(other_data);

    xdata = other_idx;
    ydata = this_idx;
    
    rank_str = ' (rank)';
  else
    xdata = other_data;
    ydata = this_data;
    
    rank_str = '';
  end
  
  plot(xdata, ydata, 'o');
  hold on;
  label_scatter_pts(xdata, ydata, patient_ids_common);
  
  data_min = min([xdata(:); ydata(:)]);
  data_max = max([xdata(:); ydata(:)]);
  plot([data_min data_max], [data_min data_max], 'r-', 'linewidth', 2);
  
  axis equal
  grid on;
  xlabel(strrep(other_fs_name, '_', '\_'));
  ylabel(strrep(this_fs_name, '_', '\_'));
  
  title(strrep(sprintf('%s  r = %0.2f %s', this_feature_names{kk}, corr(xdata(:), ydata(:)), rank_str), '_', '\_'));
  increase_font;
  
  output_filename = fullfile(output_dir, [this_feature_names{kk} '.png']);
  print_trim_png(output_filename);
  fprintf('Saved %s (%d of %d)\n', output_filename, kk, length(this_feature_names));
end
1;

function fn_cleaned = clean_feature_names(fn)
fn_cleaned = fn;
fn_cleaned = strrep(fn_cleaned, 'glcm_', '');
fn_cleaned = strrep(fn_cleaned, 'slope_', '');
fn_cleaned = strrep(fn_cleaned, 'correlation', 'corr');
fn_cleaned = strrep(fn_cleaned, 'homogeneity', 'homog');
fn_cleaned = strrep(fn_cleaned, 'area_under_curve', 'auc');

for kk = 1:length(fn_cleaned)
  if ~isempty(regexp(fn_cleaned{kk}, '^avg_', 'once'))
    fn_cleaned{kk} = [fn_cleaned{kk}(5:end) '_avg'];
  end
end
