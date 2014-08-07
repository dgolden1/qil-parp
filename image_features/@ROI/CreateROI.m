function obj = CreateROI(varargin)
% Manually create ROI on an image
% obj = CreateROI('param', value, ...)
% 
% PARAMETERS
% image: a 2D intensity image or a 3D color image
% h_ax: axis on which an existing image resides
% cmap: color map to use for intensity images (default: jet)
% x_coord_mm: scale for the X-axis of the image, in mm
% y_coord_mm: scale for the Y-axis of the image, in mm (e.g., image is plotted as
%  imagesc(x_coord_mm, y_coord_mm, img))
% 
% If neither image nor h_ax is given, the ROI will be created on the current axes
% 
% During ROI creation: delete all points or press escape to abort; press enter to finish

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id: CreateROI.m 178 2013-02-07 18:33:41Z dgolden $

%% Parse input arguments
p = inputParser;
p.addParamValue('image', []);
p.addParamValue('h_ax', []);
p.addParamValue('cmap', 'jet');
p.addParamValue('x_coord_mm', []);
p.addParamValue('y_coord_mm', []);
p.addParamValue('message_text', 'Select the region ROI');
p.addParamValue('roi_color', 'w');
p.parse(varargin{:});

if isempty(p.Results.image) && isempty(p.Results.h_ax)
  h_ax = gca;
elseif ~isempty(p.Results.h_ax)
  h_ax = p.Results.h_ax;
else
  if ndims(p.Results.image) == 3
    image(p.Results.image);
  else
    imagesc(p.Results.image);
    colormap(p.Results.cmap);
  end
  axis off;
end

%% Get ROI
zoom on;
uiwait(helpdlg(p.Results.message_text));

% Select ROI
axes(h_ax);
hold on;
roi_x = [];
roi_y = [];
h_roi = [];
[this_img_x_mm, this_img_y_mm, button] = ginput(1);
no_add = false;
while ~isempty(this_img_x_mm) && ~isequal(button, 27) % If user picked a point and didn't press esc
  if ~no_add
    roi_x(end+1) = this_img_x_mm;
    roi_y(end+1) = this_img_y_mm;
  end
  
  % Plot ROI on original image
  if ishandle(h_roi)
    delete(h_roi);
  end
  if ~isempty(roi_x)
    h_roi = plot(roi_x([1:end 1]), roi_y([1:end 1]), 'o-', 'color', p.Results.roi_color);
  end

  [this_img_x_mm, this_img_y_mm, button] = ginput(1);
  no_add = false;
  
  if ~isempty(button) && button == 27 % User pressed escape
    roi_x = [];
    roi_y = [];
    break;
  elseif ~isempty(button) && (button == 8 || button == 127) % User pressed backspace or delete
    if isempty(roi_x)
      % If we deleted all the points and delete is pressed again, then quit
      break;
    end
    
    % Otherwise, delete the last point and continue
    roi_x(end) = [];
    roi_y(end) = [];
    no_add = true;
  end
end

% User didn't make an ROI
if length(roi_x) <= 2
%   response = questdlg('Is the lesion visible?');
%   switch response
%     case 'Yes'
%       error('ROI Polygon must have more than 2 vertices');
%     case 'No'
%       roi_x = [];
%       roi_y = [];
%     case 'Cancel'
%       error('ROI specification aborted');
%   end
  if isempty(button) % Enter
    error('CreateROI:AbortedEnter', 'ROI specification aborted');
  else
    error('CreateROI:Aborted', 'ROI specification aborted');
  end
end

%% Set object properties
obj = ROI(roi_x, roi_y, p.Results.x_coord_mm, p.Results.y_coord_mm);

if isempty(p.Results.x_coord_mm)
  % If image coordinates aren't given, assume 1 mm per pixel
  img = findobj(gca, 'type', 'image');
  if length(img) ~= 1
    error('Unable to find only one image as a child of current axes');
  end
  
  xl = get(img, 'XData');
  yl = get(img, 'YData');
  obj.ImageXmm = xl(1):xl(2);
  obj.ImageYmm = yl(1):yl(2);
end

1;
