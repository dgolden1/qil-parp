function roi_poly = roi_select_points(h_ax)
%% Choose points on image map to determine ROI

% Select ROI
axes(h_ax);
hold on;
roi_poly.img_x_mm = [];
roi_poly.img_y_mm = [];
h_roi = [];
[this_img_x_mm, this_img_y_mm] = ginput(1);
no_add = false;
while ~isempty(this_img_x_mm)
  if ~no_add
    roi_poly.img_x_mm(end+1) = this_img_x_mm;
    roi_poly.img_y_mm(end+1, 1) = this_img_y_mm;
  end
  
  % Plot ROI on original image
  delete(h_roi);
  if ~isempty(roi_poly.img_x_mm)
    h_roi = plot(roi_poly.img_x_mm([1:end 1]), roi_poly.img_y_mm([1:end 1]), 'wo-');
  end

  [this_img_x_mm, this_img_y_mm, button] = ginput(1);
  no_add = false;
  
  if ~isempty(button) && (button == 8 || button == 27 || button == 127) % User pressed escape, backspace or delete (only tested on Windows PC)
    % Quit if we deleted all the points and delete is pressed again
    if isempty(roi_poly.img_x_mm)
      break;
    end
    
    roi_poly.img_x_mm(end) = [];
    roi_poly.img_y_mm(end) = [];
    no_add = true;
  end
end

if isempty(roi_poly.img_x_mm)
  error('ROI specification aborted');
end
