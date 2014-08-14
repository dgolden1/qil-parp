
function CA_dose_in_mmol_per_kg = compute_CA_dose_in_mmol_per_kg(Patient_Params, log_file, log_window_handle)

CA_dose_in_mmol_per_kg = [];

switch Patient_Params.CA_Type
  case {'Prohance', 'Magnevist', 'Omniscan'}
   CA_molarity_in_mmol_per_ml = 0.5;  
 otherwise
  process_error_msg(sprintf('Unknown contrast agent type: %s', Patient_Params.CA_Type), log_file, log_window_handle);
  return;
end

% Check that the CA dose is ok
if ~isnumeric(Patient_Params.CA_Dose)
  if isstr(Patient_Params.CA_Dose)
    disp('Contrast agent dose in Patient Params struct is a text string - converting to numeric');
    Patient_Params.CA_Dose = str2num(Patient_Params.CA_Dose);
  else
    disp('Contrast agent dose in Patient Params struct is not in a recognised format');
    return;
  end
end

if isempty(Patient_Params.CA_Dose)
  disp('Contrast agent dose in Patient Params struct is empty');
  return;
end

% Check that the patient weight is ok
if ~isnumeric(Patient_Params.Weight)
  if isstr(Patient_Params.Weight)
    disp('Patient weight in Patient Params struct is a text string - converting to numeric');
    Patient_Params.Weight = str2num(Patient_Params.Weight);
  else
    disp('Patient weight in Patient Params struct is not in a recognised format');
    return;
  end
end

if isempty(Patient_Params.Weight)
  disp('Patient Weight in Patient Params struct is empty');
  return;
end

% Finally compute the CA dose in mmol per kg of body weight
CA_dose_in_mmol_per_kg = CA_molarity_in_mmol_per_ml * Patient_Params.CA_Dose / Patient_Params.Weight;
