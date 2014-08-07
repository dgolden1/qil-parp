function CompareGLCMFeatures(pdb1, pdb2, varargin)
% Compare GLCM features between two PARPDB objects

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('output_dir', ''); % If not given, plots are not saved
p.addParamValue('db_name1', '');
p.addParamValue('db_name2', '');
p.addParamValue('b_scatterplots', true);
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

%% Get features
fs1 = CollectFeatures(pdb1, 'b_glcm', true);
fs2 = CollectFeatures(pdb2, 'b_glcm', true);

%% Get common patients
fs1 = RemovePatients(fs1, fs1.PatientIDs(setdiff(fs1.PatientIDs, fs2.PatientIDs)));
fs2 = RemovePatients(fs2, fs2.PatientIDs(setdiff(fs2.PatientIDs, fs1.PatientIDs)));
assert(isequal(fs1.PatientIDs, fs2.PatientIDs));

%% Make scatter plots
map_strings = {'auc', 'wash_in', 'wash_out', 'kep', 'ktrans', 've'};
% map_strings = {'Area Under Contrast Curve', 'Wash-In', 'Wash-Out', 'Kep', 'Ktrans', 'Ve'};

corr_struct = struct('name', {}, 'r_pearson', {}, 'r_spearman', {});
for jj = 1:length(map_strings)
  t_fig_start = now;
  
  name_idx = ~cellfun(@isempty, strfind(fs1.FeatureNames, map_strings{jj}));
  feature_names = fs1.FeatureNames(name_idx);
  feature_names_pretty = fs1.FeaturePrettyNames(name_idx);
  assert(length(feature_names) <= 6);
  
  if p.Results.b_scatterplots
    figure;
    figure_grow(gcf, 2, 1.5);
  end
  
    for kk = 1:length(feature_names)
      vals1 = GetValuesByFeature(fs1, feature_names{kk});
      vals2 = GetValuesByFeature(fs2, feature_names{kk});
      
      if p.Results.b_scatterplots
        subplot(2, 3, kk);
        plot(vals1, vals2, 'o');
        grid on;
        title(sprintf('%s (r = %0.2f)', strrep(feature_names{kk}, '_', '\_'), corr(vals1, vals2)));
        xlabel(db_name1);
        ylabel(db_name2);
      end
      
      struct_idx = length(corr_struct) + 1;
      corr_struct(struct_idx).name = feature_names_pretty{kk};
      corr_struct(struct_idx).r_pearson = corr(vals1, vals2, 'type', 'Pearson');
      corr_struct(struct_idx).r_spearman = corr(vals1, vals2, 'type', 'Spearman');
    end
    
    if p.Results.b_scatterplots
      increase_font;

      if ~isempty(p.Results.output_dir)
        output_filename = fullfile(p.Results.output_dir, sprintf('comparison_%s.png', feature_names{kk}));
        print_trim_png(output_filename);
        fprintf('Saved %s (%d of %d) in %s\n', output_filename, jj, length(map_strings), time_elapsed(t_fig_start, now));
      end
    end
end

%% Make bar plots
figure;
figure_grow(gcf, 2, 1);
bar(1:length(corr_struct), [[corr_struct.r_pearson].' [corr_struct.r_spearman].']);

xlim([0 length(corr_struct)+1]);

tick_labels = strrep(strrep({corr_struct.name}, 'Post-chemo ', ''), 'GLCM ', '');
set(gca, 'xtick', 1:length(corr_struct), 'xticklabel', tick_labels, 'ytick', 0:0.2:1);

% Shift up axis and rotate tick labels
pos = get(gca, 'position');
axis_shift = 0.5;
set(gca, 'position', [pos(1), pos(2) + axis_shift, pos(3), pos(4) - axis_shift]);

rotateticklabel(gca, 45);

legend('Pearson', 'Spearman', 'location', 'southwest');

increase_font;

output_filename = fullfile(p.Results.output_dir, sprintf('correlation_bar.png'));
print_trim_png(output_filename);
fprintf('Saved %s\n', output_filename);

1;
