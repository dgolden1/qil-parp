function debug_rcb_distribution
% Investigate why there are three RCB peaks

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

%% Setup
close all;

%% Get RCB table data
rcbs = get_rcb_table_data;

%% Figure out what RCB depends on the most
% figure;
% subplot(2, 2, 1);
% ecdf([rcbs.tumor_area_1].*[rcbs.tumor_area_2]);
% set(findobj(gca, 'Type', 'Line'), 'Linewidth', 2);
% xlabel('Area');
% 
% subplot(2, 2, 2);
% ecdf((1 - [rcbs.in_situ_percent]/100).*[rcbs.cancer_percent]/100);
% set(findobj(gca, 'Type', 'Line'), 'Linewidth', 2);
% xlabel('f_{inv}');
% 
% subplot(2, 2, 3);
% ecdf([rcbs.num_pos_nodes]);
% set(findobj(gca, 'Type', 'Line'), 'Linewidth', 2);
% xlabel('Num Nodes');
% 
% subplot(2, 2, 4);
% ecdf([rcbs.d_largest_node_met]);
% set(findobj(gca, 'Type', 'Line'), 'Linewidth', 2);
% xlabel('d_{met}');
% 
% increase_font;

%% Plot RCB CDF for different categories
% idx_pos_nodes = [rcbs.num_pos_nodes] ~= 0;
% idx_no_inv = (1 - [rcbs.in_situ_percent]/100).*[rcbs.cancer_percent]/100 == 0;
% 
% figure;
% subplot(2, 2, 1);
% ecdf([rcbs.rcb]);
% set(findobj(gca, 'Type', 'Line'), 'Linewidth', 2);
% xlabel('RCB All');
% 
% subplot(2, 2, 2);
% ecdf([rcbs(idx_pos_nodes).rcb]);
% set(findobj(gca, 'Type', 'Line'), 'Linewidth', 2);
% xlabel('RCB +Nodes');
% 
% subplot(2, 2, 3);
% ecdf([rcbs(~idx_pos_nodes).rcb]);
% set(findobj(gca, 'Type', 'Line'), 'Linewidth', 2);
% xlabel('RCB -Nodes');
% 
% subplot(2, 2, 4);
% ecdf([rcbs(idx_no_inv).rcb]);
% set(findobj(gca, 'Type', 'Line'), 'Linewidth', 2);
% xlabel('RCB No Invasive');
% 
% increase_font;

%% Test different scenarios
num_nodes_vec = 0:10;
cancer_percent_vec = linspace(0, 100);

[num_nodes_mat, cancer_percent_mat] = meshgrid(num_nodes_vec, cancer_percent_vec);

rcb_mat = calculate_rcb(17, 17, cancer_percent_mat, 0, num_nodes_mat, 5);

figure
imagesc(num_nodes_vec, cancer_percent_vec, rcb_mat);
xlabel('Num +Nodes');
ylabel('Cancer %');
c = colorbar;
ylabel(c, 'RCB');
increase_font;

%% Plot the two components of RCB separately

% Plot RCB for various values of each term
term1_vec = linspace(0, 3, 100);
term2_vec = linspace(0, 3, 100);
[term1_mat, term2_mat] = meshgrid(term1_vec, term2_vec);

rcb_mat = term1_mat + term2_mat;

figure;
imagesc(term1_vec, term2_vec, rcb_mat);
hold on;
[C, h] = contour(term1_vec, term2_vec, rcb_mat, 'k');
clabel(C, h);
axis xy;
xlabel('RCB Term 1 (Primary Tumor)');
ylabel('RCB Term 2 (Positive Nodes)');
c = colorbar;
caxis([0 6]);
ylabel(c, 'RCB');

% Plot terms for each patient
patient_term_1 = 1.4*([rcbs.f_inv].*[rcbs.d_prim]).^0.17;
patient_term_2 = (4*(1 - 0.75.^[rcbs.LN]).*[rcbs.d_met]).^0.17;
hold on;
plot(patient_term_1, patient_term_2, 'o', 'markerfacecolor', 'w', 'markeredgecolor', 'k', 'markersize', 8);
increase_font;

1;
