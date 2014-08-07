function [r_center, r_var] = centroid(r, m)
% [centr, var] = centroid(r, m)
% 
% Function to find the 1-d centroid of a vector
% 
% INPUTS
% r: distance of points from reference points (x-values)
% m: mass of points
% 
% OUTPUTS
% r_center: r value of the center of mass
% var: weighted variance (biased)
% 
% If m is a matrix, a centroid will be returned for each column
% 
% This is the same as a weighted average, with values r and weights m

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id: centroid.m 290 2013-05-31 21:18:58Z dgolden $

% Allow a matrix r and vector m
if ~isequal(size(r), size(m))
  if isvector(r) && isvector(m) && length(r) == length(m)
    % One of r or m is a row vector and one is a column vector
    m = m.';
  elseif isvector(m) && size(r, 1) == length(m) && ismatrix(r)
    % m is a vector of weights, each of which applies to a row of r
    m = repmat(m(:), 1, size(r, 2));
  else
    error('r must have number of rows equal to length(m)');
  end
end

r_center = sum(r.*m)./(sum(m));

if nargout > 1
  % See http://stats.stackexchange.com/questions/47325/bias-correction-in-weighted-variance
  % for formula
  r_center_rep = repmat(r_center, size(r, 1), 1);
  r_var = sum(m)./((sum(m)).^2 - sum(m.^2)) .* sum(m.*(r - r_center_rep).^2);
end