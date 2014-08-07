function plot_3d_surface(varargin)
% Make a nice shiny 3D plot of a surface
% plot_3d_surface(vol)
% plot_3d_surface(x, y, z, vol)
% 
% makes a surface at vol == 0

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id: plot_3d_surface.m 174 2013-02-06 00:31:19Z dgolden $


%% Parse input arguments

if nargin == 1
  vol = varargin{1};
  x = 1:size(vol, 2);
  y = 1:size(vol, 1);
  z = 1:size(vol, 3);
elseif nargin == 4
  x = varargin{1};
  y = varargin{2};
  z = varargin{3};
  vol = varargin{4};
end
  
%% Plot
hpatch = patch(isosurface(x, y, z, double(vol),0));
% isonormals(x, y, z, double(mask), hpatch)
set(hpatch,'FaceColor','red','EdgeColor','none')
view([-65,20]);
camlight left
set(gcf,'Renderer','zbuffer'); lighting phong
axis equal tight
xlabel('x');
ylabel('y');
zlabel('z');
grid on;
rotate3d on