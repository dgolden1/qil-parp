function debug_jiajing_feature_change
% I screwed up Jiajing's features when I included the kinetic maps on
% August 16, 2012. Figure out why

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

% The new code for getting features
new = load('/Users/dgolden/Documents/qil/case_studies/parp/stat_analysis_runs/stat_analysis_run_2012_08_16_1622.mat');

% The original code for getting features
orig = load('/Users/dgolden/Documents/qil/case_studies/parp/stat_analysis_runs/stat_analysis_run_2012_08_16_1642.mat');

%% Make sure feature names are the same
new_names_in_old_fmt = cellfun(@(x) strrep(x, 'post_img ', ''), new.X_names, 'UniformOutput', false);
assert(isequal(new_names_in_old_fmt, orig.X_names));

%% Make sure patient IDs are the same
assert(isequal(orig.patient_id, new.patient_id));

%% Plot feature difference map
diff_map = (new.X - orig.X)./orig.X;
zeros_orig_idx = orig.X == 0;
diff_map(zeros_orig_idx) = sign(new.X(zeros_orig_idx));

figure;
imagesc(1:length(orig.patient_id), 1:size(diff_map, 2), diff_map.');
caxis(max(abs(caxis))*[-1 1]);
colormap hotcold;
set(gca, 'ytick', 1:size(diff_map, 2), 'yticklabel', orig.X_names, 'xtick', 1:length(orig.patient_id), 'xticklabel', orig.patient_id);
zoom yon;
