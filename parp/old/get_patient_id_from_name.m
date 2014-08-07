function [patient_id, str_pre_or_post_chemo] = get_patient_id_from_name(patient_name)
% Parse patient name to get PARP patient ID number

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

if ~iscell(patient_name)
  patient_name = {patient_name};
end

for kk = 1:length(patient_name)
  this_name = upper(strrep(patient_name{kk}, ' ', '_'));
  
  if ~isempty(regexp(this_name, '^[0-9]{3}-?(PRE|POST)$'))
    patient_id(kk) = str2double(this_name(1:3));
  elseif ~isempty(regexp(this_name, '^PARP_[0-9]{3}_(PRE|POST)_MRI$'))
    patient_id(kk) = str2double(this_name(6:8));
  elseif ~isempty(regexp(this_name, '^PARP_[0-9]{3}-[0-9]{3}_(PRE|POST)_MRI$'))
    patient_id(kk) = str2double(this_name(10:12));
  else
    error('Unrecognized patient name format: %s', this_name);
  end
  
  if ~isempty(strfind(lower(this_name), 'pre')) && isempty(strfind(lower(this_name), 'post'))
      str_pre_or_post_chemo = 'pre';
  elseif isempty(strfind(lower(this_name), 'pre')) && ~isempty(strfind(lower(this_name), 'post'))
    str_pre_or_post_chemo = 'post';
  else
    str_pre_or_post_chemo = '';
    warning('Unable to determine whether patient is pre- or post-chemo from name');
  end
  
end

if iscolumn(patient_name)
  patient_id = patient_id(:);
end
