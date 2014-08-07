function feature_set = get_jafis_patterns_of_response
% Load Jafi's patterns of response from spreadsheet
% [X, X_names, patient_id] = get_jafis_patterns_of_response

% By Daniel Golden (dgolden1 at stanford dot edu) September 2012
% $Id$

% Set up spreadsheet info
xls_filename = fullfile(qilsoftwareroot, 'parp', 'PARP Lesion Locations.xlsx');
xls_sheetname = 'Lesions-POST';
columnname = 'MRI Pattern of Response';

[num, txt, raw] = xlsread(xls_filename, xls_sheetname);

patient_id = [];
patterns_of_response = {};
patient_id_col = strcmp(raw(1,:), 'Study ID');
pattern_of_response_col = strcmp(raw(1,:), columnname);
for kk = 1:size(raw, 1)
  this_patient_id = raw{kk, patient_id_col};
  this_pattern_of_response = raw{kk, pattern_of_response_col};
  
  if isnumeric(this_patient_id) && ischar(this_pattern_of_response)
    patient_id(end+1, 1) = this_patient_id;
    patterns_of_response{end+1, 1} = this_pattern_of_response;
  end
end

[X, X_names] = label_to_dummy(patterns_of_response);

feature_set = FeatureSet(X, patient_id, X_names, [], 'Patterns of Response');
