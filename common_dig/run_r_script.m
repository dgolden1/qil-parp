function r_output = run_r_script(script_filename, varargin)
% Run an R script with passed variables
% run_r_script(script_filename, 'param', value, ...)
% 
% PARAMETERS
% args: cellstring of arguments to pass from the caller, e.g., {'a', 'b', 'c'}
% b_echo: print R output to console (default: false)

% By Daniel Golden (dgolden1 at stanford dot edu) June 2013
% $Id: run_r_script.m 322 2013-07-03 18:40:04Z dgolden $

%% Parse input arguments
p = inputParser;
p.addParamValue('args', {});
p.addParamValue('b_echo', false);
p.parse(varargin{:});

%% Setup
filename_matlab_to_r = '/tmp/data_from_matlab.R';
filename_r_to_matlab = '/tmp/data_from_r.mat';

% Delete data files to ensure we don't use old data by accident
if exist(filename_matlab_to_r, 'file')
  delete(filename_matlab_to_r);
end
if exist(filename_r_to_matlab, 'file')
  delete(filename_r_to_matlab);
end

%% Save R data file
if ~iscellstr(p.Results.args)
  error('args should be cellstring of variable names to save');
end

for kk = 1:length(p.Results.args)
  this_var = evalin('caller', p.Results.args{kk});
  eval(sprintf('%s = this_var;', p.Results.args{kk}));
end
clear this_var;

saveR(filename_matlab_to_r, p.Results.args{:});

%% Run R script
setenv('DYLD_LIBRARY_PATH', ''); % Fixes a bug in Matlab's calling of R
r_cmd = sprintf('Rscript --vanilla %s', script_filename);

if p.Results.b_echo
  fprintf('Running %s\n', r_cmd);
  [status, result] = system(r_cmd, '-echo');
else
  [status, result] = system(r_cmd);
end

if status ~= 0
  error('R call failed:\n%s', result);
end

%% Collect result, if any
if exist(filename_r_to_matlab, 'file')
  r_output = load(filename_r_to_matlab);
end