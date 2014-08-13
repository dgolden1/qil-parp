function make_figure_rcb_scatterplot
% Make a figure showing a scatterplot of RCB vs the tumor and the node term
% in the RCB equation

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

%% Setup
close all;

addpath(fullfile(danmatlabroot, 'parp'));
output_dir = fullfile(dandropboxroot, 'papers', '2012_breast_cancer_heterogeneity_and_rcb', 'images');


%% Plot RCB scatterplot
debug_rcb_distribution;
figure(2);
post_process_fcn = @(x) set(findobj(x, '-property', 'linewidth'), 'linewidth', 1);
% paper_print('raw_rcb_scatter', 9, 2, output_dir, post_process_fcn);

%% Plot RCB ECDF
% patients_pre = get_processed_patient_list('pre');
% patients_post = get_processed_patient_list('post');
% patients_all = union(patients_pre, patients_post);

rcbs = get_rcb_table_data([], true);

[X_clinical, X_names_clinical, patient_id_clinical] = get_clinical_data;

% Exclude patients with NaN features other than Ki67
patient_id_clinical(isnan(X_clinical(:, strcmp(X_names_clinical, 'cycles_of_treatment_received_ 4 (all possible cycles)')))) = [];
idx_valid = ismember([rcbs.patient_id], patient_id_clinical);
rcbs = rcbs(idx_valid);

% rcbs = rcbs(ismember([rcbs.patient_id], patients_all));
rcb = [rcbs.rcb];

rcb_term_tumor = 1.4*([rcbs.f_inv].*[rcbs.d_prim]).^0.17;
rcb_term_nodes = (4*(1 - 0.75.^[rcbs.LN]).*[rcbs.d_met]).^0.17;

figure;
[f, x] = ecdf(rcb);
stairs(x, f, 'k-', 'linewidth', 1);
xlabel('RCB Value');
ylabel('Cumulative Distribution Function');
grid on;

% paper_print('raw_rcb_ecdf', 9, 2, output_dir);

%% Plot pie charts of RCB and tumor/nodes
labels_rcb(rcb == 0) = {'RCB=0'};
labels_rcb(rcb > 0 & rcb < 2.5) = {'0<RCB<2.5'};
labels_rcb(rcb >= 2.5) = {'RCB>2.5'};
pie_plot(labels_rcb);

paper_print('raw_pie_rcb_cat', 9, 2, output_dir);

labels_tumor_nodes(rcb_term_tumor == 0 & rcb_term_nodes == 0) = {'pCR'};
labels_tumor_nodes(rcb_term_tumor > 0 & rcb_term_nodes == 0) = {'Residual Tumor (no nodes)'};
labels_tumor_nodes(rcb_term_tumor == 0 & rcb_term_nodes > 0) = {'Residual Nodes (no tumor)'};
labels_tumor_nodes(rcb_term_tumor > 0 & rcb_term_nodes > 0) = {'Tumor + Nodes'};
sort_order = {'pCR', 'Residual Tumor (no nodes)', 'Tumor + Nodes', 'Residual Nodes (no tumor)'};
pie_plot(labels_tumor_nodes, sort_order);

paper_print('raw_pie_tumor_nodes', 9, 2, output_dir);
