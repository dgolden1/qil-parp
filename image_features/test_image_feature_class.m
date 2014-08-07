% Make a test ImageFeature object and mess with it

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id: test_image_feature_class.m 124 2012-12-11 23:43:40Z dgolden $

%% Setup
clear;
close all;

%% Create ImageFeature object
load('clown', 'X');
roi_x = [162 133 216 249];
roi_y = [49 79 124 83];
image_name = 'clown';
patient_id = 1;
I = ImageFeature(X, 'clown', 1, 'ROIPolyX', roi_x, 'ROIPolyY', roi_y, 'SpatialXCoords', (1:size(X, 2))/10, ...
                 'SpatialYCoords', (1:size(X, 1))/10, 'SpatialCoordUnits', 'mm', ...
                 'ImagePrettyName', 'Clown');

%% Do some stuff
%PlotImage(I);

figure;
imagesc(I.SpatialXCoords, I.SpatialYCoords, I.Image);
grid on;
h_ax(1) = gca;
I_resize = ResizeImage(I, 0.25);
figure;
imagesc(I_resize.SpatialXCoords, I_resize.SpatialYCoords, I_resize.Image);
grid on;
h_ax(2) = gca;
linkaxes(h_ax);

%FS_GLCM = GetFeatureGLCM(I, 'patient_X');

1;
