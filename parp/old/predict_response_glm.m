function predict_response_glm
% Run a generalized linear model to predict response

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
error('Obsolete; see select_model_features.m');

close all;

load('lesion_parameters.mat', 'lesions');

% Remove outliers
lesions = exclude_patients(lesions);

%% Set up predictors
X = [[lesions.patient_age]; [lesions.num_regions]; [lesions.glcm_kep_energy]].';

%% Logistic regression model on RCB score
% y_logistic = lesions.rcb_score(:) <= 1;
% 
% [b, dev, stats] = glmfit(X(:,[1 2]), y_logistic, 'binomial', 'logit');
% y_hat_logistic = glmval(b, X(:, [1 2]), 'logit');
% [tpr, fpr, thresh] = roc(y_logistic(:).', y_hat_logistic(:).');
% auc = tpr.*[0 diff(fpr)]; % Area under ROC curve


%% Normal regression on RCB value
y_norm = [lesions.rcb_val].';
[b, dev, stats] = glmfit(X, y_norm);
y_hat_norm = glmval(b, X, 'identity');


%% Group into responders and non-responders
rcb_pivot = 1;
idx_responder = [lesions.rcb_score] <= rcb_pivot;
idx_non_responder = [lesions.rcb_score] > rcb_pivot;
rcb_label(idx_responder) = {sprintf('RCB <= %0.0f', rcb_pivot)};
rcb_label(idx_non_responder) = {sprintf('RCB > %0.0f', rcb_pivot)};


%% Plot
% super_subplot parameters
nrows = 1;
ncols = 5;
hspace = 0.075;
vspace = 0;
hmargin = [0.05 0.05];
vmargin = [0.15 0.1];

figure;
figure_grow(gcf, 1.75, 0.8);


s(1) = super_subplot(nrows, ncols, 1, hspace, vspace, hmargin, vmargin);
% boxplot([lesions.patient_age], rcb_label, 'colors', 'rb');
plot(zeros(sum(idx_responder), 1), [lesions(idx_responder).patient_age], 'bo', ...
    ones(sum(idx_non_responder), 1), [lesions(idx_non_responder).patient_age], 'ro', 'markersize', 8);
xlim([-1 2]);
set(gca, 'xticklabel', []);
ylabel('Patient age (yr)');

s(2) = super_subplot(nrows, ncols, 2, hspace, vspace, hmargin, vmargin);
% boxplot([lesions.num_regions], rcb_label, 'colors', 'rb');
plot(zeros(sum(idx_responder), 1), [lesions(idx_responder).num_regions], 'bo', ...
    ones(sum(idx_non_responder), 1), [lesions(idx_non_responder).num_regions], 'ro', 'markersize', 8);
xlim([-1 2]);
set(gca, 'xticklabel', []);
ylabel('Num regions');
% title('(a) Model Predictors');

s(3) = super_subplot(nrows, ncols, 3, hspace, vspace, hmargin, vmargin);
% boxplot([lesions.glcm_kep_energy], rcb_label, 'colors', 'rb');
plot(zeros(sum(idx_responder), 1), [lesions(idx_responder).glcm_kep_energy], 'bo', ...
    ones(sum(idx_non_responder), 1), [lesions(idx_non_responder).glcm_kep_energy], 'ro', 'markersize', 8);
xlim([-1 2]);
set(gca, 'xticklabel', []);
ylabel('K_{ep} energy');

% s(4) = super_subplot(nrows, ncols, 5:6, hspace, vspace, hmargin, vmargin);
% plot(fpr, tpr, 'k', 'linewidth', 2);
% grid on;
% axis equal
% axis([0 1 0 1.05]);
% xlabel('False Postive Rate');
% ylabel('True Positive Rate');
% title('(b) Logistic ROC');

s(5) = super_subplot(nrows, ncols, 4:5, hspace, vspace, hmargin + [0.1 0], vmargin);
plot([0 4], [0 4], 'r-', 'linewidth', 2);
grid on;
hold on;
scatter([lesions.rcb_val].', y_hat_norm);
box on;
axis equal
ax = [0 1 0 1]*3.5;
axis(ax);
xlabel('Target RCB Val');
ylabel('Modeled RCB Val');
text(1, 3, sprintf('r = %0.2f', corr([lesions.rcb_val].', y_hat_norm)));
% title('(c) Regression Output');


1;
