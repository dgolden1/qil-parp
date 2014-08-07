function unit_vec = unit(vec)
% unit_vec = unit(vec)
% Returns unit vector in same direction as input vector but with length 1
% vec is an Nx3 matrix; i.e., each vector is a row vector

% By Daniel Golden (dgolden1 at stanford dot edu) December 2010
% $Id: unit.m 13 2012-08-10 19:30:42Z dgolden $

% if size(vec, 2) ~= 3 || ndims(vec) ~= 2
%   error('vec must be an Nx3 matrix');
% end

unit_vec = vec./repmat(sqrt(sum(vec.^2, 2)), 1, size(vec, 2));
