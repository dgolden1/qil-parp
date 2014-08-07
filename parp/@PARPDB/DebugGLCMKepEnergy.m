function DebugGLCMKepEnergy(obj)
% Look at how GLCM Kep Energy is predictive of RCB > 2.5

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

%% Setup
% close all;

%% Get data
fs = obj.CollectFeatures('b_glcm', true);
[response_cats, ~, patient_ids_out] = get_treatment_response(fs.PatientIDs);
glcm_kep_energy = fs.GetValuesByFeature('glcm_kep_energy');

%% Boxplot
figure;

positive_label = 'RCB>2.5';
idx_positive = strcmp(response_cats.rcb_gt25, positive_label);

xvals = idx_positive + 1;
yvals = glcm_kep_energy;
plot(xvals(idx_positive), yvals(idx_positive), 'ro');
hold on;
plot(xvals(~idx_positive), yvals(~idx_positive), 'bo');

label_scatter_pts(xvals, yvals, fs.PatientIDs);
xlim([0 3]);
% boxplot(glcm_kep_energy, response_cats.rcb_gt25);

ylabel('GLCM Kep energy');
title(sprintf('PARPDB: %s', strrep(just_filename(obj.Dirname), '_', '\_')));
grid on;
legend('RCB > 2.5', 'RCB < 2.5');
increase_font;

%% Color by category

figure;
plot(fs.PatientIDs(idx_positive), glcm_kep_energy(idx_positive), 'ro');
hold on;
plot(fs.PatientIDs(~idx_positive), glcm_kep_energy(~idx_positive), 'bo');
legend('RCB > 2.5', 'RCB < 2.5');
label_scatter_pts(fs.PatientIDs, glcm_kep_energy, fs.PatientIDs);
title(sprintf('PARPDB: %s', strrep(just_filename(obj.Dirname), '_', '\_')));
grid on
increase_font
