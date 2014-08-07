function round_vals = nearest_dan(search_vector, input_vals, return_type, b_extrap)
% Finds the nearest element of search_vector to each element of input_vals
% 
% round_vals = nearest_dan(search_vector, input_vals, return_type, b_extrap)
% 
% 
% INPUTS
% search_vector: vector of values to be searched.  Assumed to be sorted!
% input_vals: vector of values for which you're trying to find the nearest
%  value in search_vector.  Need not be sorted.
% return_type: one of:
%  'idx' (default) returns the index of the nearest value
%  'val' returns the nearest value
% b_extrap: if false (default) input_vals outside the range of
%  search_vector will be set to nan; otherwise, they will take on the first
%  or last value of search_vector

% By Daniel Golden (dgolden1 at stanford dot edu) October 2009
% $Id: nearest_dan.m 13 2012-08-10 19:30:42Z dgolden $

%% Setup
if ~exist('return_type', 'var') || isempty(return_type)
	return_type = 'idx';
end
if ~exist('b_extrap', 'var') || isempty(b_extrap)
  b_extrap = false;
end
if ~isvector(search_vector)
	error('search_vector must be a vector');
end

%% Search
% Wow, I'm dense... I should have just used this method from the beginning
% In fact, this function is redundant with interp1
if b_extrap
  idx = interp1(search_vector, 1:length(search_vector), input_vals, 'nearest', 'extrap');
else
  idx = interp1(search_vector, 1:length(search_vector), input_vals, 'nearest');
end

% The FAST way using histc
% idx = nan(size(input_vals));
% [~,bin] = histc(input_vals, search_vector(1:end-1) + diff(search_vector)/2);
% if b_extrap
%   idx_first = input_vals < search_vector(1) + diff(search_vector(1:2))/2;
%   idx_last = input_vals >= search_vector(end) - diff(search_vector(end-1:end))/2;
% else
%   idx_first = input_vals < search_vector(1) + diff(search_vector(1:2))/2 & input_vals >= search_vector(1);
%   idx_last = input_vals >= search_vector(end) - diff(search_vector(end-1:end))/2 & input_vals <= search_vector(end);
% end
% bin(bin == 0) = nan;
% 
% idx(~idx_first & ~idx_last) = bin(~idx_first & ~idx_last) + 1; % First bin is the second value
% idx(idx_first) = 1;
% idx(idx_last) = length(search_vector);

% The FASTER but still slow way
% for kk = 1:numel(input_vals)
%   if bin(kk) == 0 % value is outside range of search_vector
%     if b_extrap
%       if input_vals(kk) < search_vector(1)
%         idx(kk) = 1;
%       elseif input_vals(kk) > search_vector(end)
%         idx(kk) = length(search_vector);
%       else
%         error('input value %d is invalid', kk);
%       end
%     else
%       idx(kk) = nan;
%     end
%   elseif bin(kk) == length(search_vector)
%     idx(kk) = length(search_vector);
%   else
%     if abs(input_vals(kk) - search_vector(bin(kk))) <= abs(input_vals(kk) - search_vector(bin(kk)+1))
%       idx(kk) = bin(kk);
%     else
%       idx(kk) = bin(kk) + 1;
%     end
%   end
  
  % The SLOW way
% 	er = abs(input_vals(kk) - search_vector);
% 	[min_er, idx(kk)] = min(er);
% 	
% 	if isnan(min_er)
% 		round_vals(kk) = nan;
% 		continue;
% 	end
% end

if any(isnan(idx))
  warning('Out of range indices set to NaN');
end

switch return_type
  case 'idx'
    round_vals = idx;
  case 'val'
    round_vals = nan(size(idx));
    round_vals(~isnan(idx)) = search_vector(idx(~isnan(idx)));
  otherwise
    error('Invalid value for return_type (%s)', return_type);
end
