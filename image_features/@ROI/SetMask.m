function obj = SetMask(obj, mask, varargin)

%% Parse input arguments
p = inputParser;
p.addParamValue('method', 'bwboundaries'); % Can be 'bwboundaries' (default) or 'direct'
p.addParamValue('b_allow_multiple_rois', false); % True to allow multiple ROIs to be returned if there are multiple distinct regions in the mask; otherwise, just return the biggest region
p.parse(varargin{:});

%% Setup
if ~isequal(size(mask), obj.ImageSize)
  error('ROI Mask size [%d %d] must equal Image size [%d %d]', size(mask), obj.ImageSize);
end

%% New method: determine poly via bwboundaries
switch p.Results.method
  case 'bwboundaries'
    % We use a mask that's doubled in size to ensure that the polygon is on the OUTSIDE
    % of the pixels, not the CENTER; if the polygon is in the center of the pixels, the
    % poly2mask function (used elsewhere) has roundoff problems, where the left side of
    % the mask isn't included
    B_doubled = bwboundaries(imresize(mask, 2), 'noholes');
    B = cellfun(@(x) x/2 + 1/4, B_doubled, 'UniformOutput', false);

    % If there's more than one polygon, choose the biggest one
    if length(B) > 1 && ~p.Results.b_allow_multiple_rois
      % warning('Found %d distinct objects in mask; choosing the biggest one', length(B));

      for kk = 1:length(B)
        mask_sizes(kk) = sum(flatten(poly2mask(B{kk}(:,2), B{kk}(:,1), size(mask, 1), size(mask, 2))));
      end
      [~, idx_biggest] = max(mask_sizes);
      B = B(idx_biggest);
    end

    if isempty(B)
      % Mask is blank
      obj.ROIPolyX = [];
      obj.ROIPolyY = [];
    else
      % Allow multiple ROIs to be returned
      obj_orig = obj;
      for kk = 1:length(B)
        obj(kk) = obj_orig;
        obj(kk).ROIPolyX = B{kk}(:,2);
        obj(kk).ROIPolyY = B{kk}(:,1);
      end
    end

%% Old method: set the mask directly and delete the poly
  case 'direct'
    obj.ManualROIMask = mask;
    obj.ROIPolyX = [];
    obj.ROIPolyY = [];
%% Error check
  otherwise
    error('Invalid value for method: %s', p.Results.method);
end