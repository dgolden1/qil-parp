function [x_mm, y_mm, z_mm, slice_plane] = get_dicom_xyz(info)
% Get X, Y, Z coordinates for pixels in an image

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

% Code based on forum post here:
% http://fixunix.com/dicom/50848-image-position-patient-question-easy.html
% 
% Based on my screwing around in OsiriX, assuming a saggital view (cut with
% head up and patient facing left side of screen), X direction points
% towards the first image (patient's Left, Matlab dim 3), Y direction
% points from patient's stomach (anterior) towards patient's back
% (posterior, Matlab dim 2) and Z direction points from patient's feet
% (inferior) towards patient's head (superior, NEGATIVE Matlab dim 1)
% 
% See also Sec 2.2.2 of http://www.dclunie.com/medical-image-faq/html/part2.html

% Plot like imagesc(y_mm, z_mm, img); axis xy;

%% Parse DICOM ImagePositionPatient and ImageOrientationPatient
row = 0:(double(info(1).Rows) - 1); % 0-indexed
col = 0:(double(info(1).Columns) - 1); % 0-indexed
% row = (1:size(slices, 1)).' - 1; % 0-indexed
% col = 1:size(slices, 2) - 1; % 0-indexed

originX = info(1).ImagePositionPatient(1);
originY = info(1).ImagePositionPatient(2);
originZ = info(1).ImagePositionPatient(3);
rowDirX = info(1).ImageOrientationPatient(1);
rowDirY = info(1).ImageOrientationPatient(2);
rowDirZ = info(1).ImageOrientationPatient(3);
colDirX = info(1).ImageOrientationPatient(4);
colDirY = info(1).ImageOrientationPatient(5);
colDirZ = info(1).ImageOrientationPatient(6);
spacingBetweenRows = info(1).PixelSpacing(1);
spacingBetweenCols = info(1).PixelSpacing(2);

%% Get maps of X, Y and Z coordinates for a single slice
[Row, Col] = ndgrid(row, col);
X_mm = originX + Row*colDirX*spacingBetweenRows + Col*rowDirX*spacingBetweenCols;
Y_mm = originY + Row*colDirY*spacingBetweenRows + Col*rowDirY*spacingBetweenCols;
Z_mm = originZ + Row*colDirZ*spacingBetweenRows + Col*rowDirZ*spacingBetweenCols;

%% Choose slice plane
% Slice plane normal is the coordinate that varies the least across the image
dir_ranges = cellfun(@(x) abs(diff(quantile(x(:), [0 1]))), {X_mm, Y_mm, Z_mm});
[~, dir_min_variation] = min(dir_ranges);
switch dir_min_variation
  case 1
    slice_plane = 'sagittal'; % Slices go from patient's left to patient's right
  case 2
    slice_plane = 'coronal'; % Slices go from anterior to posterior
  case 3
    slice_plane = 'axial'; % Slices go from inferior to superior
end

%% Get coordinates based on slice plane
idx_center_row = ceil(length(row)/2);
idx_center_col = ceil(length(col)/2);

switch slice_plane
  case 'sagittal'
    % Take coordinates from the center of the image
    x_mm = interp2(linspace(0, 1, length(col)), linspace(0, 1, length(row)), X_mm, 0.5, 0.5);
    %x_mm = X_mm(1);

    y_mm = Y_mm(idx_center_row, :);
    z_mm = Z_mm(:, idx_center_col);
  case 'coronal'
    x_mm = X_mm(idx_center_row, :);
    y_mm = interp2(linspace(0, 1, length(col)), linspace(0, 1, length(row)), Y_mm, 0.5, 0.5);
    z_mm = Z_mm(:, idx_center_col);
  case 'axial'
    x_mm = X_mm(idx_center_row, :);
    y_mm = Y_mm(:, idx_center_col);

    % Take z_mm from the center of the image
    z_mm = interp2(linspace(0, 1, length(col)), linspace(0, 1, length(row)), Z_mm, 0.5, 0.5);
    % z_mm = Z_mm(1);
  otherwise
    error('Invalid slice plane: %s', slice_plane);
end

1;
