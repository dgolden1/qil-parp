function patient_id_str = patient_id_tostr(patient_id, b_always_cellstr)
% Convert patient ID to a string

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id: patient_id_tostr.m 333 2013-07-08 21:50:28Z dgolden $

%% Setup
if ~exist('b_always_cellstr', 'var') || isempty(b_always_cellstr)
  b_always_cellstr = false;
end

if isempty(patient_id) && ischar(patient_id)
  patient_id_str = '';
elseif isempty(patient_id)
  patient_id_str = {};
  return;
end

%% If patient ID is already in the right format, return it
if ischar(patient_id) || iscellstr(patient_id)
  patient_id_str = patient_id;
  return;
end

%% Determine patient ID format
b_integer = fpart(patient_id) == 0 & patient_id < 1e3;
b_decimal = fpart(patient_id) ~= 0 & patient_id < 1e3 & fpart(patient_id*1e3) == 0;
if all(b_integer)
  format_str = 'integer';
elseif all(b_decimal)
  format_str = 'decimal';
else
  error('Unrecognized numerical format for patient ID: %f', patient_id(find(~b_integer & ~b_decimal, 1)));
end

%% Convert
if any(isnumeric(patient_id) & (patient_id >= 1000 | patient_id < 1))
  error('Patient ID must be between 1 and 1000');
end

patient_id_str = cell(size(patient_id));
for kk = 1:length(patient_id)
  if b_integer
    % Format: an integer between 0 and 999
    patient_id_str{kk} = num2str(patient_id(kk), '%03d');
  elseif b_decimal
    % Format: xxx.xxx
    patient_id_str{kk} = num2str(patient_id(kk), '%03.3f');
  end
end

%% Return a string if there's only one patient_id
if length(patient_id_str) == 1 && ~b_always_cellstr
  patient_id_str = patient_id_str{1};
end
