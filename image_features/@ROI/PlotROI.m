function PlotROI(obj, varargin)
% Plot ROI
% PARAMETERS
% roi_color: color of ROI (default: 'r')
% b_zoom_to_roi: set to true to zoom to the ROI (default: true)
% b_length_marker: set to true to plot a length marker showing the size of the ROI
%  (default: true)
% b_caxis_from_roi: set to true to determine the color axis based on pixels within
%  the ROI vs. pixels for the whole image (default: false)
% cax_quantile: the quantile of image values used to determine the color axis
%  (default: [0.01 0.99])
% image: the image over which to plot the ROI; only required if b_caxis_from_roi
%  is true

% By Daniel Golden (dgolden1 at stanford dot edu) September 2012
% $Id: PlotROI.m 290 2013-05-31 21:18:58Z dgolden $

%% Parse input arguments
p = inputParser;
p.addParamValue('roi_color', 'r');
p.addParamValue('b_zoom_to_roi', true);
p.addParamValue('b_length_marker', true); % Plot a marker indicating lesion size
p.addParamValue('b_caxis_from_roi', false); % Set the color scale based on pixels in the ROI versus in the whole image
p.addParamValue('cax_quantile', [0.01 0.99]); % Only applies if b_caxis_from_roi is true
p.addParamValue('image', []); % Required if b_caxis_from_roi is true
p.parse(varargin{:});

%% Set X and Y coordinates
if ~isempty(obj.ROIPolyX)
  x_px = obj.ROIPolyX([1:end 1]);
  y_px = obj.ROIPolyY([1:end 1]);
else
  % Note that since b_outer_radius is true in GetMaskBoundPixels, the ROI mask does NOT
  % include the plotted ROI vertices
  [x_px, y_px] = GetMaskBoundPixels(obj, true);
end

if obj.bPlotInmm
  [x, y] = px_to_mm(obj.ImageXmm, obj.ImageYmm, x_px, y_px);
else
  x = x_px;
  y = y_px;
end

%% Plot
if ~isempty(obj.ROIPolyX)
  linespec = '-';
else
  linespec = 'o';
end

plot(x, y, linespec, 'color', p.Results.roi_color, 'linewidth', 2, 'markersize', 6, 'markerfacecolor', p.Results.roi_color);

%% Do other stuff
if p.Results.b_zoom_to_roi
  PlotZoomToROI(obj);
end
if p.Results.b_length_marker
  PlotDrawLengthMarker(obj, 'line_color', p.Results.roi_color);
end
if p.Results.b_caxis_from_roi && ~isempty(p.Results.image)
  caxis(quantile(p.Results.image(obj.ROIMask), p.Results.cax_quantile));
elseif p.Results.b_caxis_from_roi
  error('If b_caxis_from_roi, ''image'' must be given as a parameter');
end
