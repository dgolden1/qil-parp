function H = jet_with_white(n, num_to_fade)
% The jet colorbar, smoothly fading to white
% 
% INPUTS
% n: length of colormap
% num_to_fade: number of values in the colormap that are smoothly fading
%  from blue to white

% By Daniel Golden (dgolden1 at stanford dot edu) November 2011
% $Id: jet_with_white.m 13 2012-08-10 19:30:42Z dgolden $

if ~exist('n', 'var') || isempty(n)
  n = 64;
end
if ~exist('num_to_fade', 'var') || isempty(num_to_fade)
  num_to_fade = 3;
end

j = jet(n - num_to_fade);

H = [interp1([1; num_to_fade + 1], [1 1 1; j(1,:)], (1:num_to_fade).'); j];
