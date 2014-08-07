function [patient_id, str_pre_or_post_chemo] = GetPatientIDFromFilename(filename)
% Get patient ID from filename

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

[dirname, filename] = fileparts(filename);

if isempty(regexp(filename, 'patient_[0-9]{3}_(pre)|(post)', 'once'))
  error('Filename is not in expected format (patient_nnn_pre or patient_nnn_post');
end

patient_id = str2double(filename(9:11));
str_pre_or_post_chemo = dirname;
