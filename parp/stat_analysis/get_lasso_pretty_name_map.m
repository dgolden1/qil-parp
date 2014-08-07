function lasso_name_map = get_lasso_pretty_name_map
% Get mapping from lasso struct name to pretty names

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

lasso_name_map = containers.Map;
lasso_name_map('rcb_cont') = 'RCB Continuous';
lasso_name_map('rcb_pcr') = 'pCR';
lasso_name_map('rcb_gt25') = 'RCB > 2.5';
lasso_name_map('rcb_2or3') = 'RCB 0/I vs II/III';
lasso_name_map('rcb_3') = 'RCB III';
lasso_name_map('nodes') = 'Residual Nodes';
lasso_name_map('tumor') = 'Residual Tumor';
lasso_name_map('tumor_and_nodes') = 'Resid Tumor + Nodes';
lasso_name_map('resid_tumor_and_nodes') = 'Resid Tumor + Nodes';
