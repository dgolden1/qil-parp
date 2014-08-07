function obj = UpdateAllCoordinates(obj, info)
% Set all DICOM coordinate-related fields except for DICOMCoordsmm, XCoordmm and
% YCoordmm, which take too much memory

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$
  
if ~exist('info', 'var') || isempty(info)
  info = dicominfo(obj.Filename);
end

[obj.XCoordmm, obj.YCoordmm, obj.XLabel, obj.YLabel, obj.SliceCoordmm, obj.SliceLabel, obj.SlicePlane] = GetImageCoordinates(obj, info);
