function mask = GetTightenedLungMask(obj, varargin)
% Get an ROI mask that conforms to the lesion more tightly than the original mask, by
% masking out normal lung
% 
% Meant for Lung CT
% 
% PARAMETERS
% tightening_thresh: threshold for tightening (default: -400)

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('tightening_thresh', -400);
p.parse(varargin{:});

%% Run
roi_mask_3d_original = obj.MyROI3D.GetROIMask;

% Exclude pixels below threshold
roi_mask_3d_new = roi_mask_3d_original & (obj.ImageVolume > p.Results.tightening_thresh);

% Morphologically close to reduce gaps in ROI
SE = strel('disk', 2); % Radius chosen empirically
roi_mask_3d_new_closed = imclose(roi_mask_3d_new, SE);

mask = roi_mask_3d_new_closed;
