function make_patient_scan_rcb_pie_chart
% Make a pie chart of patients with distribution of pre scans, post scans
% and RCB

% By Daniel Golden (dgolden1 at stanford dot edu) September 2012
% $Id$

si = get_spreadsheet_info;

patient_ids_all = [si.study_id];
patient_ids_pre = get_processed_patient_list('pre');
patient_ids_post = get_processed_patient_list('post');
patient_ids_rcb = patient_ids_all(isfinite([si.rcb_value]));

column_names = {'pre', 'post', 'rcb'};
columns = [ismember(patient_ids_all, patient_ids_pre).', ...
           ismember(patient_ids_all, patient_ids_post).', ...
           ismember(patient_ids_all, patient_ids_rcb).'];

n_pre_post_rcb = sum(all(columns, 2));
n_pre_nopost_rcb = sum(columns(:,1) & ~columns(:,2) & columns(:,3));
n_pre_post_norcb = sum(columns(:,1) & columns(:,2) & ~columns(:,3));
n_pre_nopost_norcb = sum(columns(:,1) & ~columns(:,2) & ~columns(:,3));
n_other = length(patient_ids_all) - (n_pre_post_rcb + n_pre_nopost_rcb + n_pre_post_norcb + n_pre_nopost_norcb);

pie([n_pre_post_rcb, n_pre_nopost_rcb, n_pre_post_norcb, n_pre_nopost_norcb, n_other], ...
    {'pre, post, RCB', 'pre, no post, RCB', 'pre, post, no RCB', 'pre, no post, no RCB', 'other'});
