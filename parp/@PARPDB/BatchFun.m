function results = BatchFun(obj, fun_handle, varargin)
% Run some PARPDCEMRIImage method over all PARPDCEMRIImage objects in the database and
% return the result as a cell array
% results = BatchFun(obj, fun_handle, 'param', value, ...)
% 
% INPUTS
% obj: PARPDB object
% fun_handle: function that takes in a PARPDCEMRIImage object and (optionally) returns
%  the modified PARPDCEMRIImage object
% 
% PARAMETERS
% b_save_modified_PDMIs: If the given PARPDCEMRIImage method returns a modified
%  PARPDCEMRIImage, add it to the database, replacing the old PARPDCEMRIImage (default:
%  false)
% patient_id_subset: only run on a subset of patient ids (default: all patient ids)
% b_process_fun: pass in a function handle that takes the patient ID as input
%  and returns true or false, relating to whether to process a given patient
% fun_args: arguments passed to the function (which might not be 'parameter', value type
%  arguments)
% 
% Unmatched parameters are passed to the function

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('b_save_modified_PDMIs', false);
p.addParamValue('patient_id_subset', []);
p.addParamValue('b_process_fun', []);
p.addParamValue('fun_args', {});
[args_in, args_out] = arg_subset(varargin, p.Parameters);
p.parse(args_in{:});

args_out = [p.Results.fun_args, args_out];

%% Choose subset of patients to process
patient_ids = GetPatientList(obj);

if ~isempty(p.Results.patient_id_subset)
  patient_ids = intersect(patient_ids, p.Results.patient_id_subset);
end

% Choose patients based on b_process_fun
if ~isempty(p.Results.b_process_fun)
  b_process = true(size(patient_ids));
  for kk = 1:length(patient_ids)
    b_process(kk) = p.Results.b_process_fun(patient_ids(kk));
  end
  patient_ids(~b_process) = [];
end

%% Loop over patients
for kk = 1:length(patient_ids)
  t_start = now;
  PDMI = GetPatientImage(obj, patient_ids(kk));
  
  if nargout > 0 || p.Results.b_save_modified_PDMIs
    results{kk} = fun_handle(PDMI, args_out{:});
    
    if p.Results.b_save_modified_PDMIs
      if ~strcmp(class(results{kk}), class(PDMI))
        error('Function %s returns a %s; it must return a %s', func2str(fun_handle), class(results{kk}), class(PDMI));
      end
      AddToDB(obj, results{kk});
    end
  else
    fun_handle(PDMI, varargin{:});
  end
  
  fprintf('Processed patient %s (%d of %d) in %s\n', patient_id_tostr(PDMI.PatientID), kk, length(patient_ids), time_elapsed(t_start, now));
end
