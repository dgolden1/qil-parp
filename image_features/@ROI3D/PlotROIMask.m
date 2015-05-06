function PlotROIMask(obj)
% Plot the ROI mask in 3D with some neat camera effects and stuff

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id$

%% Load mask
persistent mask x y z last_obj
if ~isequal(obj, last_obj)
  mask = GetROIMask(obj);

  % Downsample mask if it's really big
  num_mask_pixels = sum(mask(:));
  % downsample_factor = 1;
  downsample_factor = ceil(log(num_mask_pixels)/8); % I chose this formula empirically

  mask = mask(1:downsample_factor:end, 1:downsample_factor:end, 1:downsample_factor:end);

  x = obj.ImageXmm(1:downsample_factor:end);
  y = obj.ImageYmm(1:downsample_factor:end);
  z = obj.ImageZmm(1:downsample_factor:end);
  
  last_obj = obj;
end

%% Plot
figure;
hpatch = patch(isosurface(x, y, z, double(mask),0));
% isonormals(x, y, z, double(mask), hpatch)
set(hpatch,'FaceColor','red','EdgeColor','none')
view([-65,20]);
camlight left;
camlight(180, -45);
set(gcf,'Renderer','zbuffer'); lighting phong
axis equal tight
xlabel('x (mm)');
ylabel('y (mm)');
zlabel('z (mm)');
grid on;
rotate3d on
