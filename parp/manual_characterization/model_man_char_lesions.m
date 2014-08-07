function model_man_char_lesions
% Make a model for RCB using manual lesion categorizations

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Setup
close all;
addpath(fullfile(qilsoftwareroot, 'parp'));


%% Parse lesion labels
im_types = {'sub_img', 'ktrans', 'kep', 've'};

last_patient_id_list = [];
for kk = 1:length(im_types)
  this_filename = ['manually_categorized_lesions_' im_types{kk} '.mat'];
  load(this_filename, 'category', 'patient_id');

  % Make sure patient lists for all categories are the same
  if ~isempty(last_patient_id_list)
    assert(isequal(sort(last_patient_id_list), sort(patient_id)));
  end
  
  % Sort by patient id so that each column represents the same id across
  % different categories
  [~, sort_idx] = sort(patient_id);
  these_categories = cellfun(@(x) [im_types{kk} '_' x], category(sort_idx), 'UniformOutput', false);
  category_matrix(:,kk) = these_categories;
  patient_id = patient_id(sort_idx);
  
  last_patient_id = patient_id;
end

%% Exclude patient 14 which has NaN RCB
idx_valid = patient_id ~= 14;
patient_id = patient_id(idx_valid);
category_matrix = category_matrix(idx_valid, :);

%% Create dummmy variables and feature matrix
X = ones(size(patient_id, 1), 1); % Constant
X_names = {'Constant'};

for kk = 1:size(category_matrix, 2)
  these_categories = nominal(category_matrix(:,kk));
  these_dummys = dummyvar(these_categories);
  these_dummy_names = getlabels(these_categories); % Name of each dummy column
  
  % Eliminate last column or else, when a constant is added to X, X will be
  % rank deficient
  these_dummys = these_dummys(:,1:end-1);
  these_dummy_names = these_dummy_names(1:end-1);
  
  X = [X these_dummys];
  X_names = [X_names these_dummy_names];
end

%% Output RCB and categories
ssinfo = get_spreadsheet_info(patient_id);
rcb = [ssinfo.rcb_value].';

rcb_cat = 1 + rcb > 0 + rcb > 2.5; % 1: RCB=0 --- 2: 0<RCB<2.5 --- 3: RCB>2.5

%% Only choose patients for which we have all the data
idx_valid = isfinite(rcb) & all(isfinite(X), 2);
assert(all(idx_valid));
rcb = rcb(idx_valid);
rcb_cat = rcb_cat(idx_valid);
X = X(idx_valid, :);

%% Run lasso to predict continuous RCB
[b, fitinfo] = lasso(X, rcb, 'cv', 10);

lassoPlot(b, fitinfo,'PlotType','CV');
title(sprintf('Predict RCB Continuous'));
increase_font
print_trim_png('~/temp/lasso_rcb_cont_cv');

lassoPlot(b, fitinfo, 'PlotType', 'Lambda', 'xscale', 'log')
title(sprintf('Predict RCB Continuous'));
increase_font(gcf, 14);
print_trim_png('~/temp/lasso_rcb_cont_lambda');

%% Run lasso to predict RCB == 0
[b, fitinfo] = lassoglm(X, rcb == 0, 'binomial', 'cv', 10);

lassoPlot(b, fitinfo,'PlotType','CV');
title('Predict RCB=0');
increase_font
print_trim_png('~/temp/lasso_rcb_eq_0_cv');

lassoPlot(b, fitinfo, 'PlotType', 'Lambda', 'xscale', 'log');
title('Predict RCB=0');
increase_font(gcf, 14);
print_trim_png('~/temp/lasso_rcb_eq_0_lambda');

%% Run lasso to predict RCB >= 2.5
[b, fitinfo] = lassoglm(X, rcb >=2.5, 'binomial', 'cv', 10);

lassoPlot(b, fitinfo,'PlotType','CV');
title('Predict RCB>2.5');
increase_font
print_trim_png('~/temp/lasso_rcb_gt_25_cv');

lassoPlot(b, fitinfo, 'PlotType', 'Lambda', 'xscale', 'log');
title('Predict RCB>2.5');
increase_font(gcf, 14);
print_trim_png('~/temp/lasso_rcb_gt_25_lambda');

% rcb_hat = 1./(1 + exp(X*b(:, fitinfo.Index1SE)));
% plotroc(rcb.' < 2.5, rcb_hat.');
% plotconfusion(rcb.' >= 2.5, rcb_hat.' < 0.4)
% print_trim_png('~/temp/lasso_rcb_gt_25_confusion');


1;
