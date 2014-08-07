function g = green(n)
% Creates a colormap that goes from black to green to white, a la classic
% IMAGE EUV images (http://euv.lpl.arizona.edu/euv/index.html)

% By Daniel Golden (dgolden1 at stanford dot edu) December 2009
% $Id: green.m 13 2012-08-10 19:30:42Z dgolden $

if ~exist('n', 'var') || isempty(n)
	n = 64;
end

if mod(n, 2)
	error('n must be an even number (n=%d)', n);
end

n2 = n/2;
n2m1 = n/2 - 1;

g1 = 0.8; % Most green

g = [[zeros(n2, 1), [0:n2m1].'/n2*g1, zeros(n2, 1)];
	[[0:n2m1].'/n2m1, g1 + [0:n2m1].'/n2m1*(1 - g1), [0:n2m1].'/n2m1]];
