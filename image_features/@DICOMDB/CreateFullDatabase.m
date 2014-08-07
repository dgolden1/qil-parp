function obj = CreateFullDatabase(obj, dicom_dir, db_filename)
% Make a DICODMB database from a directory of DICOM images

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

%% Setup
b_parallel = true;

obj_class = class(obj);
if ~exist('dicom_dir', 'var') || isempty(dicom_dir)
  if ismethod(obj, 'GetDefaultDICOMDir')
    dicom_dir = eval(sprintf('%s.GetDefaultDICOMDir', obj_class));
  end
  if ~ismethod(obj, 'GetDefaultDICOMDir') || isempty(dicom_dir)
    error('dicom_dir not provided and no method %s.GetDefaultDICOMDir', obj_class);
  end
end

if ~exist('db_filename', 'var') || isempty(db_filename)
  if ismethod(obj, 'GetDefaultDBFilename')
    db_filename = eval(sprintf('%s.GetDefaultDBFilename', obj_class));
  end
%   if ~ismethod(obj, 'GetDefaultDBFilename') && isempty(db_filename)
%     error('db_filename not provided and no method %s.GetDefaultDBFilename', obj_class);
%   end
end

%% Get list of files
% Find files, excluding DICOMDIR files and anything that begins with a period
if isunix
  t_start = 0;
  [filelist, elapsed_time] = find_files_unix(dicom_dir, '-type f | grep -v DICOMDIR | grep -v "/\\."');
  t_end = elapsed_time;
else
  t_start = now;
  filelist = find_files_general('', dicom_dir, 1)';
  filelist = filelist(cellfun(@isempty, regexp(just_filename(filelist), '(DICOMDIR)|(^\.)')));
  t_end = now;
end
fprintf('Found %d DICOM files in %s in %s\n', length(filelist), dicom_dir, time_elapsed(t_start, t_end));

%% Collect info from each file in parallel
% Enable parallel stuff

if b_parallel && exist('matlabpool', 'file') && matlabpool('size') == 0
  matlabpool('open');
elseif ~b_parallel && exist('matlabpool', 'file') && matlabpool('size') > 0
  matlabpool('close');
end

parfor_temp_dirname = parfor_progress_init;
filelist_length = length(filelist);

% warning('parfor disabled');
% for kk = 1:filelist_length
% for kk = [1923, 3846, 5769, 7212];
parfor kk = 1:filelist_length
  t_start = now;
  
  this_dicom_image = DICOMImage(filelist{kk});
  dicom_list(kk) = this_dicom_image;

  iteration_number = parfor_progress_step(parfor_temp_dirname, kk);
  fprintf('Processed DICOM header %d of %d in %s\n', iteration_number, filelist_length, time_elapsed(t_start, now));
end
parfor_progress_cleanup(parfor_temp_dirname);

% Get rid of any skipped files
idx_valid = ~cellfun(@isempty, {dicom_list.SlicePlane});
dicom_list(~idx_valid) = [];
if sum(~idx_valid) > 0
  fprintf('Removed %d invalid files from database\n', sum(~idx_valid));
end

%% Create DICOM database
obj = eval(sprintf('%s(dicom_list)', obj_class));

%% Save
if exist('db_filename', 'var') && ~isempty(db_filename)
  obj.DBFilename = db_filename;
  SaveDB(obj);
end

1;
