function round_vals = nearest(input_vals, search_vector, return_type)
% round_vals = nearest(input_vals, search_vector, return_type)
% Finds the nearest element of search_vector to each element of input_vals
% 
% return_type can be one of:
%  'idx' (default) returns the index of the nearest value
%  'val' returns the nearest value
% 
% NOTE: This function is obsolete, since I wrote it without realizing that
% nearest neighbor interpolation does the same thing
% 
% in general, if I wrote:
% blah = nearest(A, B)
% it can be replaced with
% blah = interp1(B, 1:length(B), A, 'nearest', 'extrap')
% 
% The only catch is that, using interp1, B has to be monotonic

% By Daniel Golden (dgolden1 at stanford dot edu) October 2009
% $Id: nearest.m 13 2012-08-10 19:30:42Z dgolden $

if ~exist('return_type', 'var') || isempty(return_type)
	return_type = 'idx';
end

if ~isvector(search_vector)
	error('search_vector must be a vector');
end

round_vals = nan(size(input_vals));
for kk = 1:numel(input_vals)
	er = abs(input_vals(kk) - search_vector);
	[min_er, i] = min(er);
	
	if isnan(min_er)
		round_vals(kk) = nan;
		continue;
	end

	switch return_type
		case 'idx'
			round_vals(kk) = i;
		case 'val'
			round_vals(kk) = search_vector(i);
		otherwise
			error('Invalid value for return_type (%s)', return_type);
	end
end
