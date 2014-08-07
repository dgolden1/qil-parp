function [obj, sort_idx] = SortDB(obj)
% Sort database by patient ID, series description and filename

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

sort_idx = multi_sort({obj.DICOMList.PatientID}, {obj.DICOMList.SeriesDescription}, {obj.DICOMList.Filename});
obj.DICOMList = obj.DICOMList(sort_idx);
obj = RefreshMaps(obj);
