function [args_in, args_out] = arg_subset(args, args_to_keep)
% Parse out a subset of parameters for 'parameter', value, ...  -- type args
% [args_in, args_out] = arg_subset(args, args_to_keep)
%
% OUTPUTS
% args_in: arguments that are a subset of args_to_keep
% args_out: all other arguments
% 
% E.g.
% p = inputParser;
% p.addParamValue('blah', []);
% [args_in, args_out] = arg_subset(varargin, p.Parameters);
% p.parse(args_in{:});
% some_subfunction(args_out{:});

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id: arg_subset.m 240 2013-04-08 19:52:27Z dgolden $

%% Setup
if mod(length(args), 2) ~= 0
  error('Must have an even number of input arguments');
end
if ~iscell(args)
  error('args must be a cell array of parameter-value arguments');
end
if ~iscellstr(args(1:2:end))
  error('Odd-numbered values in args cell array must be strings');
end
if ~iscellstr(args_to_keep)
  error('args_to_keep must be a cell string list of parameters to keep');
end

%% Run
arg_names_all = args(1:2:end);
b_keep_param = ismember(arg_names_all, args_to_keep);

b_keep_param_val = false(size(args));
b_keep_param_val(1:2:end) = b_keep_param;
b_keep_param_val(2:2:end) = b_keep_param;

args_in = args(b_keep_param_val);
args_out = args(~b_keep_param_val);