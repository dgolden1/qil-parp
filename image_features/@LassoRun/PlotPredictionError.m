function PlotPredictionError(obj)
% Plot prediction error for each patient

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id$

[predicted_values, dev, cv_pred_se, cv_pred_mean, cv_dev] = GetPredictedValuesFull(obj);

%% Plot predicted values
figure;

h_predicted = plot(predicted_values, 'ko');
hold on;
e = errorbar(cv_pred_mean, cv_pred_se*1.96);
set(e, 'linestyle', 'none');
xlabel('Patient');
ylabel('Predicted \mu');
set(gca, 'xtick', 1:length(predicted_values), 'xticklabel', obj.ThisFeatureSet.PatientIDs);
xlim([0, length(predicted_values) + 1]);
grid on;
increase_font;

h_fake_line = plot(0, 0, 'b-');
legend([h_predicted, h_fake_line], 'Full Output', 'CV 95%', 'Location', 'SouthEast');

%% Plot deviance
figure;

b = bar(dev, 'facecolor', [1 1 1]*0.7);
hold on;
e = errorbar(mean(cv_dev, 2), std(cv_dev, [], 2)*1.96);
dot = plot(0, 0, 'k');

set(e, 'linestyle', 'none', 'color', 'k');
set(gca, 'xtick', 1:length(predicted_values), 'xticklabel', obj.ThisFeatureSet.PatientIDs);
xlabel('Patient');
ylabel('Deviance');

legend([b, dot], 'Full Model', 'CV 95%');

xlim([0, length(predicted_values) + 1]);
grid on;
increase_font;

figure_grow(gcf, 2, 1);
