function stats_struct = GetSomeImageStats(obj)
% Get some statistics about the image
% stats_struct = GetSomeImageStats(obj)

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Run
stats_struct.patient_id = obj.PatientID;
stats_struct.pixel_spacing = obj.PixelSpacing;
stats_struct.slice_thickness = obj.ImageInfo(1).SliceThickness;
stats_struct.series_name = obj.ImageInfo(1).SeriesDescription;
stats_struct.dt = median(diff([obj.Time]));
stats_struct.dt_max = max(diff([obj.Time]));
stats_struct.b_registered = obj.b_IsRegistered;
stats_struct.num_time_points = length(obj.ImageInfo);
stats_struct.institution_name = obj.ImageInfo(1).InstitutionName;
stats_struct.manufacturer = obj.ImageInfo(1).Manufacturer;

if ~isempty(obj.MyROI)
  stats_struct.lesion_size = sum(flatten(obj.MyROI.ROIMask))*obj.PixelSpacing^2;
else
  stats_struct.lesion_size = nan;
end


if isfield(obj.ImageInfo(1), 'ReceiveCoilName')
  stats_struct.receive_coil_name = obj.ImageInfo(1).ReceiveCoilName;
else
  stats_struct.receive_coil_name = 'N/A';
end

acquisition_date = obj.ImageInfo(1).AcquisitionDate;
year = str2double(acquisition_date(1:4));
month = str2double(acquisition_date(5:6));
day = str2double(acquisition_date(7:8));
stats_struct.image_date = datenum([year, month, day, 0, 0, 0]);

if isempty(obj.MyROI)
  stats_struct.roi_num_pts = nan;
else
  stats_struct.roi_num_pts = length(obj.MyROI.ROIPolyX);
end
