function AddToDB(obj, PDMI)
% Add a PARPDCEMRIImage object to the ImageList and sort by patient ID

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

%% Resize to common resolution
if ~isempty(obj.CommonPixelSpacing)
  if PDMI.PixelSpacing > obj.CommonPixelSpacing*1.05
    % Don't decrease the pixel size (increase the resolution) of any images
    error('Pixel size for patient %03d (%0.2f) is larger than common pixel size (%0.2f)', ...
      PDMI.PatientID, PDMI.PixelSpacing, obj.CommonPixelSpacing);
  end

  if abs(PDMI.PixelSpacing - obj.CommonPixelSpacing)/obj.CommonPixelSpacing > 0.01
    % Resize if pixelspacing differs from desired pixelspacing by more than 1%
    PDMI = ResizeImage(PDMI, 'new_pixel_spacing', obj.CommonPixelSpacing);
  end
end


%% Save
filename = GetPatientFilenameFromID(obj, PDMI.PatientID);
if exist(filename, 'file')
  b_overwriting = true;
else
  b_overwriting = false;
end

save_object_properties(filename, PDMI, 'b_save_dependent_vars', true);
% save(filename, 'PDMI');

if b_overwriting
  fprintf('Replaced patient %03d in database (%s)\n', PDMI.PatientID, filename);
else
  fprintf('Added patient %03d to database (%s)\n', PDMI.PatientID, filename);
end
