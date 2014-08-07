function print_patient_info_for_paper(patient_ids)
% Print some demographic information about patients that would be used for
% a "materials" section of a paper

% By Daniel Golden (dgolden1 at stanford dot edu) September 2012
% $Id$

if ~exist('patient_ids', 'var') || isempty(patient_ids)
  % 55 Patient IDs for which we got BI-RADS features as of September 2012
  patient_ids = [1 2 3 4 5 6 7 8 9 10 11 13 16 17 19 20 21 22 23 24 25 27 28 31 32 33 ...
                 34 35 36 37 38 40 41 42 45 46 47 48 49 50 52 53 54 55 57 58 59 60 63 ...
                 64 65 66 69 70 71];
end

si = get_spreadsheet_info(patient_ids);

fprintf('Num patients: %d\n', length(patient_ids));
fprintf('Median age: %d; range: %d--%d\n', median([si.pre_mri_age]), min([si.pre_mri_age]), max([si.pre_mri_age]));
fprintf('pre-chemo MRIs performed between %s and %s\n', datestr(min([si.pre_mri_date]), 29), datestr(max([si.pre_mri_date]), 29))
