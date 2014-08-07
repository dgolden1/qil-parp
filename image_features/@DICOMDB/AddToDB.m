function obj = AddToDB(obj, dicom_image, b_sort)
% Add a DICOM file to the database

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

if ~exist('b_sort', 'var') || isempty(b_sort)
  b_sort = true;
end

if obj.MapUID.isKey(dicom_image.SOPInstanceUID)
  error('A DICOM file with this UID already exists in the database');
end
if obj.MapFilename.isKey(dicom_image.Filenaem)
  error('A DICOM file with this filename already exists in the database');
end

obj.DICOMList(end+1) = dicom_image;
obj.MapUID(dicom_image.SOPInstanceUID) = length(obj.DICOMList);
obj.MapFilename(dicom_image.Filename) = length(obj.DICOMList);

if b_sort
  obj = SortDB(obj);
end
