function manually_categorized_lesion_compare
% Compare RCB of some lesions which were manually categorized

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Setup
close all;
addpath(fullfile(qilsoftwareroot, 'parp'));

categorized_lesion_filename = 'manually_categorized_lesions_sub_img.mat'; % Subtraction images
% categorized_lesion_filename = 'manually_categorized_lesions_ktrans.mat'; % ktrans maps
% categorized_lesion_filename = 'manually_categorized_lesions_kep.mat'; % ktrans maps
% categorized_lesion_filename = 'manually_categorized_lesions_ve.mat'; % ktrans maps

load(categorized_lesion_filename, 'category', 'patient_id');
categories = unique(category);

%% Get RCB
spreadsheet_info = get_spreadsheet_info;
[~, spreadsheet_idx] = ismember(patient_id, [spreadsheet_info.study_id]);
assert(all(spreadsheet_idx > 0));

patient_id_check = [spreadsheet_info(spreadsheet_idx).study_id].';
assert(isequal(patient_id_check, patient_id));

rcb = [spreadsheet_info(spreadsheet_idx).rcb_value];

%% Make matrix of statistically significant difference between different categories
h_kstest = nan(length(categories)); % True if the null hypothesis is rejected at 5% significane
p_kstest = nan(length(categories)); % p-value

for jj = 1:length(categories)
  for kk = 1:length(categories)
    category_1 = categories{jj};
    category_2 = categories{kk};
    
    rcb_1 = rcb(strcmp(category, category_1));
    rcb_1 = rcb_1(isfinite(rcb_1));
    rcb_2 = rcb(strcmp(category, category_2));
    rcb_2 = rcb_2(isfinite(rcb_2));
    
    idx = sub2ind(size(h_kstest), jj, kk);
    
    % According to the Matlab documentation, the kstest is not valid if
    % this is not true
    if length(rcb_1)*length(rcb_2)/(length(rcb_1) + length(rcb_2)) >= 4
      % Alternate hypothesis: rcb_1 > rcb_2
      % Null hypothesis: rcb_1 <= rcb_2
      [h_kstest(idx), p_kstest(idx)] = kstest2(rcb_1, rcb_2, 0.05, 'larger');
    end
  end
end

figure;
[new_image_data, new_color_map, new_cax] = colormap_white_bg(h_kstest, jet, [0 1]);
imagesc(new_image_data);
colormap(new_color_map);
caxis(new_cax);
for kk = 1:length(categories)
  ylabels{kk} = sprintf('%s %d', categories{kk}, kk);
end
set(gca, 'ytick', 1:length(categories), 'yticklabel', ylabels, 'xtick', 1:length(categories));
title('Red if null hypothesis (rcb_{left} <= rcb_{bottom}) is rejected');
increase_font;

print_trim_png('~/temp/man_cat_kstest_matrix');

%% Make box-whisker plot for each category
figure;
boxplot(rcb, category);
ylabel('RCB');
figure_grow(gcf, 2, 1);
increase_font;

print_trim_png('~/temp/man_cat_rcb_boxplot');

%% Make ksdensity plots for each category
xi = linspace(0, 6);
pdf_est = nan(length(categories), length(xi));
for kk = 1:length(categories)
  pdf_est(kk, :) = ksdensity(rcb(strcmp(category, categories{kk})), xi, 'width', 0.25);
end

figure;
plot(xi, pdf_est, 'linewidth', 2);
xlabel('RCB');
ylabel('Kernel density estimate');
legend(strrep(categories, '_', ' '));
figure_grow(gcf, 1.75, 1);
increase_font

print_trim_png('~/temp/man_cat_rcb_ksdensity');

%% Make bar plots of number of each image category in each RCB category
rcb_categories = {'RCB=0', '0<RCB<2.5', 'RCB>2.5'};

morph_rcb_cat_matrix = nan(length(categories), length(rcb_categories));
for kk = 1:length(categories)
  these_rcbs = rcb(strcmp(category, categories{kk}));
  morph_rcb_cat_matrix(kk, 1) = sum(these_rcbs == 0);
  morph_rcb_cat_matrix(kk, 2) = sum(these_rcbs > 0 & these_rcbs < 2.5);
  morph_rcb_cat_matrix(kk, 3) = sum(these_rcbs >= 2.5);
end

figure;
bar(morph_rcb_cat_matrix, 1);
legend(rcb_categories);
set(gca, 'xtick', 1:length(categories), 'xticklabel', strrep(categories, '_', ' '));
grid on;
increase_font;
figure_grow(gcf, 2, 1);

print_trim_png('~/temp/man_cat_distr');

%% Make bar plot of proportion of pCR patients
frac_pcr = nan(length(categories), 1);
for kk = 1:length(categories)
  this_rcb_distr = rcb(strcmp(category, categories{kk}));
  frac_pcr(kk) = sum(this_rcb_distr == 0)/length(this_rcb_distr);

  [ac_mean(kk), ac_pm(kk)] = agresti_coull(length(this_rcb_distr), sum(this_rcb_distr == 0), 0.05);
end

% Get agresti coull error bars

figure;
b = bar(1:length(categories), frac_pcr);
set(b, 'facecolor', [1 1 1]*0.5);
hold on
errorbar(1:length(categories), ac_mean, ac_pm, 'k', 'linestyle', 'none');
set(gca, 'xticklabel', categories);
ylabel('Fraction pCR');
title('Error bars are 95% confidence');
yl = ylim;
ylim([0 yl(2)]);
figure_grow(gcf, 2, 1);
increase_font;

print_trim_png('~/temp/man_cat_pcr_prop');

%% Make bar plot of proportion of RCB > 2.5 patients
frac_gt_25 = nan(length(categories), 1);
for kk = 1:length(categories)
  this_rcb_distr = rcb(strcmp(category, categories{kk}));
  frac_gt_25(kk) = sum(this_rcb_distr > 2.5)/length(this_rcb_distr);

  [ac_mean(kk), ac_pm(kk)] = agresti_coull(length(this_rcb_distr), sum(this_rcb_distr > 2.5), 0.05);
end

% Get agresti coull error bars

figure;
b = bar(1:length(categories), frac_gt_25);
set(b, 'facecolor', [1 1 1]*0.5);
hold on
errorbar(1:length(categories), ac_mean, ac_pm, 'k', 'linestyle', 'none');
set(gca, 'xticklabel', categories);
ylabel('Fraction RCB > 2.5');
title('Error bars are 95% confidence');
yl = ylim;
ylim([0 yl(2)]);
figure_grow(gcf, 2, 1);
increase_font;

print_trim_png('~/temp/man_cat_gt25_prop');

%% Plot empirical CDFs for each category
xi = linspace(0, 6);
figure;
hold on;
colors = get(gca, 'colororder');
for kk = 1:length(categories)
  [ecdfs{kk}, ecdfs_x{kk}] = ecdf(rcb(strcmp(category, categories{kk})));
  stairs(ecdfs_x{kk}, ecdfs{kk}, 'linewidth', 2, 'color', colors(kk,:));
end

xlabel('RCB');
ylabel('Empirical CDF');
legend(strrep(categories, '_', ' '), 'location', 'southeast');
box on;
grid on
increase_font;

print_trim_png('~/temp/man_cat_ecdf');
