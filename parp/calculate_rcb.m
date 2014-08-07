function [rcb, d_prim, f_inv, LN, d_met] = calculate_rcb(tumor_area_1, tumor_area_2, cancer_percent, in_situ_percent, num_pos_nodes, d_largest_node_met)
%% Function: compute RCB
% See Symmans 2007 doi: 10.1200/JCO.2007.10.6823

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$


d_prim = sqrt(tumor_area_1.*tumor_area_2);
f_inv = (1 - in_situ_percent/100).*cancer_percent/100;
LN = num_pos_nodes;
d_met = d_largest_node_met;
rcb = 1.4*(f_inv.*d_prim).^0.17 + (4*(1 - 0.75.^LN).*d_met).^0.17;
