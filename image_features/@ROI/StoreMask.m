function obj = StoreMask(obj)
% Store the ROI mask for computationally cheaper later retrieval

% By Daniel Golden (dgolden1 at stanford dot edu) May 2013
% $Id: StoreMask.m 290 2013-05-31 21:18:58Z dgolden $

obj.ManualROIMask = obj.ROIMask;