function obj = LoadDB(obj, dirname, b_verbose)
% Load database from a file

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

%% Setup
if ~exist('dirname', 'var') || isempty(dirname)
  dirname = obj.Dirname;
end
if ~exist('b_verbose', 'var') || isempty(b_verbose)
  b_verbose = true;
end

%% Load
filename = fullfile(dirname, 'parpdb.mat');

load(filename, 'str_pre_or_post_chemo', 'common_pixel_spacing', 'dir_suffix');

%% Assign properties
obj = PARPDB;
obj.Dirname = dirname;
obj.PreOrPostChemo = str_pre_or_post_chemo;
obj.CommonPixelSpacing = common_pixel_spacing;

% obj = PARPDB(str_pre_or_post_chemo, dir_suffix);

%% Print
if b_verbose
  fprintf('Loaded %s\n', filename);
end
