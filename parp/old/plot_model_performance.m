function plot_model_performance(y, y_hat, patient_ids, num_features, str_err_type)
% Plot output of regression modeling

% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id$


% str_err_type can be Training or Prediction
assert(strcmp(str_err_type, 'Training') || strcmp(str_err_type, 'Prediction'));

% Determine Stanford patients
str_pre_or_post = 'pre';
b_is_stanford_patient = is_stanford_scan(patient_ids, str_pre_or_post);

% Plot
figure;
ax_lim = [min([0; y; y_hat]) - 0.1, max([3; y; y_hat]) + 0.1];

plot(ax_lim, ax_lim, 'k-', 'linewidth', 2);
hold on;
h(1) = plot(y(b_is_stanford_patient), y_hat(b_is_stanford_patient), 'o', 'markeredgecolor', 'r', 'markerfacecolor', 'r');
label{1} = 'High Time Res';
if any(~b_is_stanford_patient)
  h(2) = plot(y(~b_is_stanford_patient), y_hat(~b_is_stanford_patient), 'o', 'markeredgecolor', 'b', 'markerfacecolor', 'b');
  label{2} = 'Low Time Res';
end
box on;

label_scatter_pts(y, y_hat, patient_ids);

legend(h, label, 'Location', 'SouthEast');

axis equal
axis([ax_lim ax_lim]);

grid on;
xlabel('Target RCB');
ylabel('Modeled RCB');

if ~isempty(num_features)
  features_str = sprintf(', %d features', num_features);
else
  features_str = '';
end
title(sprintf('%s error, %d patients%s, r^2 = %0.2f, RMS Err = %0.2f', str_err_type, ...
  length(y), features_str, corr(y, y_hat)^2, sqrt(mean((y - y_hat).^2))));

increase_font;
