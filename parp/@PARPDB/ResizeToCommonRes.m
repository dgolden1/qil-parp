function obj = ResizeToCommonRes(obj, common_pixel_spacing, varargin)
% Resize all images to a common pixel size, possibly by either resizing the PK maps or
% re-creating them
% 
% If b_remake_maps is false (default), kinetic maps will be resized using imresize
%  function; otherwise, they will be recreated from downsampled image stacks
% If b_error_on_increase_res is true (default) then patients with resolution lower than
%  the target resolution will trigger an error; otherwise, they will be removed from the
%  database

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('b_remake_maps', false);
p.addParamValue('b_error_on_increase_res', true);
p.parse(varargin{:});


%% Loop
patient_ids = GetPatientList(obj);

for kk = 1:length(patient_ids)
  t_start = now;
  PDMI = GetPatientImage(obj, patient_ids(kk));
  
  try
    PDMI_resized = ResizeImage(PDMI, 'new_pixel_spacing', common_pixel_spacing, 'b_remake_maps', p.Results.b_remake_maps);
  catch er
    if strcmp(er.identifier, 'ResizeImage:EnlargeImage') && ~p.Results.b_error_on_increase_res
      fprintf('Removing patient %s from database because resolution (%0.2f) is lower than target resolution (%0.2f)\n', ...
        patient_id_tostr(patient_ids(kk)), PDMI.PixelSpacing, common_pixel_spacing);
      obj.RemoveFromDB(patient_ids(kk));
      continue;
    else
      rethrow(er);
    end
  end
  
  AddToDB(obj, PDMI_resized);
  
  fprintf('Processed patient %d of %d in %s\n', kk, length(patient_ids), time_elapsed(t_start, now));
end

obj.CommonPixelSpacing = common_pixel_spacing;
SaveDB(obj);
