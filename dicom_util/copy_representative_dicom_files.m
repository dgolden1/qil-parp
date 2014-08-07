function copy_representative_dicom_files(source_dir, dest_dir, varargin)
% Copy one dicom file for each subdirectory to a common directory

% By Daniel Golden (dgolden1 at stanford dot edu) September 2012
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('first_or_last', 'first'); % Copy the 'first', 'last' or 'both' files from the directory
p.addParamValue('clear_dest_dir', false); % Clear the destination directory
p.parse(varargin{:});

%% Setup
if ~exist(dest_dir, 'dir')
  mkdir(dest_dir);
end

%% Clear destination directory
d = dir(dest_dir);
d(cellfun(@(x) x(1) == '.', {d.name})) = []; % Remove files and directories that start with .
if p.Results.clear_dest_dir && ~isempty(d)
  for kk = 1:length(d)
    delete(fullfile(dest_dir, d(kk).name));
  end
  fprintf('Removed %d files from %s\n', length(d), dest_dir);
end

%% Get list of directories
d = dir(source_dir);
d = d(cellfun(@(x) x(1) ~= '.', {d.name})); % Get rid of dirs and files that start with .
d_dirs = d([d.isdir]);
d_files = d(~[d.isdir]);

%% Recurse on subdirectories
for kk = 1:length(d_dirs)
  copy_representative_dicom_files(fullfile(source_dir, d_dirs(kk).name), dest_dir, 'first_or_last', p.Results.first_or_last);
end

%% Copy representative file from this directory, if any
if ~isempty(d_files)
  switch p.Results.first_or_last
    case 'first'
      idx = 1;
    case 'last'
      idx = length(d_files);
    case 'both'
      idx = [1 length(d_files)];
  end
  
  for kk = 1:length(idx)
    output_filename = [just_filename(source_dir) '-' d_files(idx(kk)).name];
    input_full_filename = fullfile(source_dir, d_files(idx(kk)).name);
    output_full_filename = fullfile(dest_dir, output_filename);

    copyfile(input_full_filename, output_full_filename);

    fprintf('Copied %s to %s\n', input_full_filename, output_full_filename);
  end
end
