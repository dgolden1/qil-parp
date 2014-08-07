function plot_model_params
% Make a mess of box-whisker plots for lesion parameters for patients with
% favorable and unfavorable RCBs

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
error('Obsolete: see plot_model_features.m');

close all;

plot_output_dir = '~/temp';

load('lesion_parameters.mat', 'lesions');

%% Remove outliers
lesions = exclude_patients(lesions);

%% Plot distribution of RCBs
% Score (quantized)
figure;
hist([lesions.rcb_score], length(unique([lesions.rcb_score])));
grid on;
yl = ylim;
set(gca, 'xtick', min([lesions.rcb_score]):max([lesions.rcb_score]), 'ytick', yl(1):yl(end));
xlabel('RCB Score (quantized)');
ylabel('Count');
increase_font;

% Value (real number)
figure;
hist([lesions.rcb_val], 5);
grid on;
yl = ylim;
% set(gca, 'xtick', min([lesions.rcb_score]):max([lesions.rcb_score]), 'ytick', yl(1):yl(end));
xlabel('RCB Value');
ylabel('Count');
increase_font;


%% Group into responders and non-responders
rcb_pivot = 1;
idx_responder = [lesions.rcb_score] <= rcb_pivot;
idx_non_responder = [lesions.rcb_score] > rcb_pivot;
rcb_label(idx_responder) = {sprintf('RCB <= %0.0f', rcb_pivot)};
rcb_label(idx_non_responder) = {sprintf('RCB > %0.0f', rcb_pivot)};


%% Lesion averaged parameters

figure;
set(gcf, 'Name', 'Averaged parameters');
subplot(3, 3, 1);
boxplot([lesions.avg_ktrans], rcb_label);
ylabel('K_{trans}');

subplot(3, 3, 2);
boxplot([lesions.avg_kep], rcb_label);
ylabel('K^{ep}');

subplot(3, 3, 3);
boxplot([lesions.avg_ve], rcb_label);
ylabel('V_e');

subplot(3, 3, 4);
boxplot([lesions.avg_wash_in], rcb_label);
ylabel('wash-in (CU/min)');

subplot(3, 3, 5);
boxplot([lesions.avg_wash_out], rcb_label);
ylabel('wash-out (CU/min)');

subplot(3, 3, 6);
boxplot([lesions.avg_auc], rcb_label);
ylabel('auc (CU)');

subplot(3, 3, 7);
boxplot([lesions.patient_age], rcb_label);
ylabel('Patient age (yr)');

subplot(3, 3, 8);
boxplot([lesions.lesion_area], rcb_label);
ylabel('Lesion size (mm^2)');

subplot(3, 3, 9);
boxplot([lesions.num_regions], rcb_label);
ylabel('Num regions');

this_filename = fullfile(plot_output_dir, 'lesion_avg_params.png');
% print('-dpng', '-r90', this_filename);
% fprintf('Saved %s\n', this_filename);

%% Gray-level co-occurrence matrix parameters
glcm_names = fieldnames(lesions);
glcm_names(cellfun(@isempty, strfind(glcm_names, 'glcm'))) = [];

figure;
set(gcf, 'Name', 'GLCM PK Texture');
for kk = 1:12
  subplot(3, 4, kk);
  
  boxplot([lesions.(glcm_names{kk})], rcb_label);
  ylabel(strrep(strrep(glcm_names{kk}, 'glcm_', ''), '_', ' '));
end

this_filename = fullfile(plot_output_dir, 'lesion_texture_pk.png');
% print('-dpng', '-r90', this_filename);
% fprintf('Saved %s\n', this_filename);


figure;
set(gcf, 'Name', 'GLCM Empirical Texture');
for kk = 1:12
  subplot(3, 4, kk);
  
  boxplot([lesions.(glcm_names{kk+12})], rcb_label);
  ylabel(strrep(strrep(glcm_names{kk+12}, 'glcm_', ''), '_', ' '));
end

this_filename = fullfile(plot_output_dir, 'lesion_texture_empirical.png');
% print('-dpng', '-r90', this_filename);
% fprintf('Saved %s\n', this_filename);

