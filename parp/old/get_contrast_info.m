function [contrast_injection_time, chem_name, dose, b_known_protocol] = get_contrast_info(info_struct, t)
% Get contrast agent info for a given series based on its DICOM info struct
% [injection_time_sec, chem_name, dose, b_known_protocol] = get_contrast_info(info_struct)
% 
% This is based on stuff that Bruce Daniel (bdaniel@stanford.edu) told me
% in person for Stanford scans, and, based on telephone conversations with
% the MRI technicians for other centers

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

% According to the Magnevist data sheet, page 8
% http://www.berlex.com/html/products/pi/Magnevist_PI.pdf
% 1 mmol magnevist is 2 mL

series_description = info_struct(1).SeriesDescription;

b_is_stanford_scan = ~isempty(strfind(lower(series_description), 'spiral')) || ...
                     ~isempty(strfind(series_description, 'WATER')) || ...
                     ~isempty(strfind(series_description, 'Multiphase')) || ...
                     length(t) > 15;

% There's pretty much only 1 contrast agent
chem_name = 'magnevist'; % Gadolinium-based contrast agent

patient_id = get_patient_id_from_name(info_struct(1).PatientName.FamilyName);

b_known_protocol = true;

if b_is_stanford_scan
  switch series_description
    case 'Ax Multiphase Wash In'
      % Empirically determined for patient 063-PRE
      contrast_injection_time = 130;
    
    case {'WATER:DISCO 3 reg (old)', 'WATER:DISCO 4d mrk new', 'WATER:DISCO 4D mrk new'}
      t_unique = unique(t);

      % Contrast APPEARS to be injected in the below third time points for
      % these pre-chemo patients --DIG 2012-09-27
      if patient_id == 58
        contrast_injection_time = t_unique(3);
      elseif patient_id == 68
        contrast_injection_time = 130;
      elseif patient_id == 103
        contrast_injection_time = 30;
      end

    case {'WATER:DISCO 4D'}
      t_unique = unique(t);
      contrast_injection_idx = 3;
      contrast_injection_time = t_unique(contrast_injection_idx);

    otherwise
      contrast_injection_time = 40; % Sec after first image
  end
  
  dose = 0.1; % mmol/kg
else
  institution_name = info_struct(1).InstitutionName;

  switch institution_name
    case {'CAL PACIFIC MED CTR', 'Cal Pacific Med Ctr MR2'}
      % Injected with beginning of first image, but since each scan takes a
      % long time to complete, the "effective" injection time is really
      % half an image interval earlier
      contrast_injection_time = t(2) - median(diff(t(2:end)))/2; % Injected with first POST image
      dose = 0.1; % mmol/kg
    case {'Kaiser South San Francisco'}
      contrast_injection_time = t(2) - median(diff(t(2:end)))/2; % Same time as first POST image
      dose = 0.1; % mmol/kg
    case {'Santa Cruz Medical Foundation', 'PAMF Santa Cruz'}
      contrast_injection_time = t(2) - 40 - median(diff(t(2:end)))/2; % 40 sec before first post-contrast image
      patient_weight = info_struct(1).PatientWeight;
      if patient_weight < 25 || patient_weight > 100
        error('Illogical value for patient weight: %0.2G kg', patient_weight);
      end
      dose = 10/patient_weight; % 20 mL = 10 mmol for all patients
    otherwise
      % I made all this up. I need to contact the institutions which
      % performed the MRI to get real numbers --DIG 2012-02-22

      warning('get_contrast_info:unknownInfo', 'Unknown contrast info for sequence ''%s'' at institution ''%s''; using made-up values', ...
        series_description, institution_name);
      
      b_known_protocol = false;
      
      contrast_injection_time = t(2) - median(diff(t(2:end)))/2; % Formerly t(2) - 40
      dose = 0.1; % mmol/kg
  end
end
