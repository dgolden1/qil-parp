function test_r_coxph_lasso
% Test run of Cox PH model with Lasso penalization via Matlab-R interface

% By Daniel Golden (dgolden1 at stanford dot edu) June 2013
% $Id: test_r_coxph_lasso.m 327 2013-07-04 23:32:14Z dgolden $

%% Setup
close all;

%% Make some fake data
rng('default'); % Reproducible random values

num_patients = 50;
num_features = 10;
num_real_features = 2;

feature_names = cellfun(@(x) ['feature ' num2str(x, '%03d')], num2cell(1:num_features), 'uniformoutput', false);
patient_names = cellfun(@(x) ['patient ' num2str(x, '%03d')], num2cell(1:num_patients), 'uniformoutput', false);

x = rand(num_patients, num_features)*20/num_real_features;
noise = rand(num_patients, 1)*5;
event_times = sum(x(:,1:num_real_features), 2) + noise;

% Randomly censor some values
b_censored = randi(2, num_patients, 1) == 2;

% Randomly subtract up to 5 months from the censored data set; ensure that the time values are still at least 1
event_times(b_censored) = max(event_times(b_censored) - randi(5, sum(b_censored), 1), 1);

b_save_plots = false;
alpha = 1;

%% Make original survival curves, stratified by non-bogus features
sum_real_features = sum(x(:,1:num_real_features), 2);
idx_lower_risk = sum_real_features > median(sum_real_features); % Lower risk = longer survival
times_low_risk = event_times(idx_lower_risk);
b_censored_low_risk = b_censored(idx_lower_risk);
times_high_risk = event_times(~idx_lower_risk);
b_censored_high_risk = b_censored(~idx_lower_risk);

figure;
h_low_risk = plot_survival(times_low_risk, b_censored_low_risk, 'h_ax', gca, 'color', 'b');
h_high_risk = plot_survival(times_high_risk, b_censored_high_risk, 'h_ax', gca, 'color', 'r');
xlabel('Time');
legend([h_low_risk(1), h_high_risk(1)], 'Low Risk', 'High Risk', 'Location', 'SouthWest');
increase_font;


%% Run via LassoRun class
fs = FeatureSet(x, patient_names, feature_names, [], '', '');
fs.Response = struct('event', num2cell(~b_censored), 'time', num2cell(event_times));
fs.ResponseName = 'Fake Response';
lasso_run = LassoRun(fs, [], [], 'mcreps', 1, 'alpha', 1, 'ncvfolds', 10, 'b_clear_existing_plots', false);

1;