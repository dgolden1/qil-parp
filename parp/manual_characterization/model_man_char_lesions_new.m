function model_man_char_lesions_new
% Make a model for RCB using manual lesion categorizations

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Setup
close all;
addpath(fullfile(qilsoftwareroot, 'parp'));


%% Parse lesion labels
load('manually_categorized_lesions_sub_img_new.mat', 'patient_id', 'feature_names', 'feature_vals');

%% Create dummmy variables and feature matrix
X = [ones(size(feature_vals, 1), 1) feature_vals];
X_names = [{'Constant'} feature_names];

assert(all(isfinite(X(:))));


%% Output RCB and categories
ssinfo = get_spreadsheet_info(patient_id);
rcb = [ssinfo.rcb_value].';

assert(all(isfinite(rcb)));

rcb_cat = 1 + rcb > 0 + rcb > 2.5; % 1: RCB=0 --- 2: 0<RCB<2.5 --- 3: RCB>2.5

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
