function H = hotcold(n, pow, center_gray_level)
% The hot-cold colormap
% 
% INPUTS
% n: number of colors; if n is even, there will be two bins which are all
%  white. Default: 64
% pow: set to 1 (default) for linear progression of color; set to a higher
%  power for less white and to a lower power for more white
% center_gray_level: set to 1 to fade to white (default); set to a lower
%  number to fade to gray

% By Daniel Golden (dgolden1 at stanford dot edu) October 2008
% $Id: hotcold.m 13 2012-08-10 19:30:42Z dgolden $

%% Setup
if ~exist('n', 'var') || isempty(n)
	n = 64;
end
if ~exist('pow', 'var') || isempty(pow)
  pow = 1;
end
if ~exist('center_gray_level', 'var') || isempty(center_gray_level)
  center_gray_level = 1;
end


%% Zero is black
% r = [zeros(floor(n/2), 1); (linspace(0, 1, ceil(n/2)).^pow).'];
% g = zeros(n, 1);
% b = [(linspace(1, 0, ceil(n/2)).^pow).'; zeros(floor(n/2), 1)];

%% Zero is white
r = [(linspace(0, 1, ceil(n/2)).^pow).'; ones(floor(n/2), 1)];
g_top = (linspace(0, 1, floor(n/2)).^pow).';
g_bottom = (linspace(1, 0, floor(n/2)).^pow).';
if mod(n, 2) == 0
  g = [g_top; g_bottom];
else
  g = [g_top; 1; g_bottom];
end
b = [ones(floor(n/2), 1); (linspace(1, 0, ceil(n/2)).^pow).'];

H_orig = [r g b];

H_hsv = rgb2hsv(H_orig);
H_hsv(:,3) = 1 - g*(1 - center_gray_level); % Use the same formula for the green channel on the value channel

H = hsv2rgb(H_hsv);
1;
