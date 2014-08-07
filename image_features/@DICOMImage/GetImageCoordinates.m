function [x_coord_mm, y_coord_mm, x_label, y_label, slice_location_mm, slice_label, plane_name] = GetImageCoordinates(obj, info)
% Get DICOM image coordinates
% [x_coord_mm, y_coord_mm, x_label, y_label, slice_location_mm, slice_label, plane_name] = GetImageCoordinates(obj, info)

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

if ~exist('info', 'var') || isempty(info)
  info = obj.DICOMInfo;
end

if ~isfield(info, 'ImageOrientationPatient')
  error('GetImageCoordinates:NoOrientation', 'DICOM File without ImageOrientationPatient: %s', obj.Filename);
end

% A kludge: some patients have weird, tilted values of info.ImageOrientationPatient;
% specifically, the plane is not perpendicular to the z direction. Artificially
% un-tilt them so get_dicom_xyz() runs correctly
% UPDATE March 1, 2013: I fixed this in get_img_coords.m
% if info.ImageOrientationPatient(3) ~= 0 || info.ImageOrientationPatient(6) ~= 0
%   warning('Patient %s Sequence %s is tilted in a weird way: [%0.2G %0.2G %0.2G; %0.2G %0.2G %0.2G]', ...
%     obj.PatientID, obj.SeriesDescription, info.ImageOrientationPatient);
%   info.ImageOrientationPatient(3) = 0;
%   info.ImageOrientationPatient(6) = 0;
% end

% Get image coordinates
[x_mm, y_mm, z_mm] = get_dicom_xyz(info);
[x_coord_mm, y_coord_mm, x_label, y_label, slice_location_mm, slice_label, plane_name] = get_img_coords(x_mm, y_mm, z_mm);
