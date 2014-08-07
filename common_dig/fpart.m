function dec = fpart(float)
% Return the floating part of the number
% 
% For a negative number, the result is negative

% By Daniel Golden (dgolden1 at stanford dot edu) June, 2008
% $Id: fpart.m 50 2012-09-21 23:46:27Z dgolden $

idx_pos = float >= 0;
dec(idx_pos) = float(idx_pos) - floor(float(idx_pos));
dec(~idx_pos) = float(~idx_pos) - ceil(float(~idx_pos));

dec = reshape(dec, size(float));