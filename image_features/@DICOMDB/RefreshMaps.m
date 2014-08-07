function obj = RefreshMaps(obj)
% Remake the UID and Filename maps

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

obj.MapUID = containers.Map('KeyType', 'char', 'ValueType', 'double');
obj.MapFilename = containers.Map('KeyType', 'char', 'ValueType', 'double');

for kk = 1:length(obj.DICOMList)
  obj.MapUID(obj.DICOMList(kk).SOPInstanceUID) = kk;
  obj.MapFilename(obj.DICOMList(kk).Filename) = kk;
end
