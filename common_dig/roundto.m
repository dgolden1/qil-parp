function x_round = roundto(x, n_mult, fhandle)
% Round a number to the nearest multiple of some number
% x_round = roundto(x, n_mult, fhandle)
% 
% Can also be used for ceil or floor
% 
% INPUTS
% x: the number to be rounded
% n_mult: round to a multiple of n_mult
% fhandle: "round" function handle, generally one of @round (default),
%  @ceil or @floor)
% 
% OUTPUTS
% x_round: the rounded number
% 
% EXAMPLES
% 
% roundto(111.111, 0.1)
% ans =
%   111.1000
% 
% roundto(111.111, 10)
% ans =
%    110

% By Daniel Golden (dgolden1 at stanford dot edu) January 2012
% $Id: roundto.m 13 2012-08-10 19:30:42Z dgolden $

%% Setup
if ~isscalar(n_mult)
  error('n_mult must be a scalar');
end

if ~exist('fhandle', 'var') || isempty(fhandle)
  fhandle = @round;
end

%% Round
x_round = fhandle(x/n_mult)*n_mult;
