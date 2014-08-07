function [dist, idx] = distance_from_a_to_b(vec_a, vec_b)
% Find the distance from each element of vec_a to the closest element in vec_b
% [dist, idx] = distance_from_a_to_b(vec_a, vec_b)
% 
% OUTPUTS
% dist: vector of size(vec_a) of (signed) distances. Since dist is signed, if
%  the closest element in vec_b to a value in vec_a is smaller than that value in
%  vec_a, dist will be negative
% idx: vector of size(vec_a) of the index into vec_b which is nearest to each
%  element of vec_a

% By Daniel Golden (dgolden1 at stanford dot edu) June 2012
% $Id: distance_from_a_to_b.m 13 2012-08-10 19:30:42Z dgolden $

idx = interp1(vec_b, 1:length(vec_b), vec_a, 'nearest', 'extrap');
dist = flatten(vec_b(idx)) - flatten(vec_a);
