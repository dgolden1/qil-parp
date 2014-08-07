function new_filelist = copy_pared_data(fileList, destinationFolder, start_sec, duration, new_suffix, b_use_newdate, b_interleaved)
% new_filelist = copy_pared_data(fileList, destinationFolder, start_sec, duration, new_suffix, b_use_newdate, b_interleaved)
% Function to take a piece of a continuous file and save it as a new file
% 
% INPUTS
% destinationFolder: folder to which truncated files will be saved 
% fileList: cell array of file names, including full path names
% start_sec: second offset in original file at which to start new file
% duration: duration of new files
% new_suffix: suffix to append to filenames to distinguish them from
% originals
% b_use_newdate: true to rename the file to reflect its new start date
% b_interleaved: true for interleaved data

% Originally by Ryan Said
% Modified by Daniel Golden (dgolden1 at stanford dot edu) May 2009
% $Id: copy_pared_data.m 13 2012-08-10 19:30:42Z dgolden $

%% Setup
if ~exist('fileList', 'var') || isempty(fileList)
	fileList = {'/home/dgolden/temp/file_trunc_test/BB085000.mat'};
end
if ~exist('destinationFolder', 'var') || isempty(destinationFolder)
	destinationFolder = '/home/dgolden/temp/file_trunc_test';
end
if ~exist('start_sec', 'var') || isempty(start_sec)
	start_sec = 0;  %[seconds]
end
if ~exist('duration', 'var') || isempty(duration)
	duration = 2*100;   %[seconds]
end
if ~exist('new_suffix', 'var') || isempty(new_suffix)
	new_suffix = '';    %set as '' if don't want to change
end
if ~exist('b_use_newdate', 'var') || isempty(b_use_newdate)
	b_use_newdate = true;
end
if ~exist('b_interleaved', 'var') || isempty(b_interleaved)
	b_interleaved = false;
end

if ~iscell(fileList) && ischar(fileList)
	fileList = {fileList};
end

%% Do stuff
fs = 1e5;
size = round(fs*duration);
offset = round(fs*start_sec);

if b_interleaved
	size = size*2;
	offset = offset*2;
end

increment = [0, floor(start_sec/60), rem(start_sec,60)];

new_filelist = cell(length(fileList), 1);
for ii = 1:length(fileList)
    new_filelist{ii} = resizeData(destinationFolder, fileList{ii}, ...
		{'data','start_minute','start_second'}, [size,1,1], [offset,0,0], ...
		increment, new_suffix, b_use_newdate);
end

% If there's only one output file, return the name of it, instead of a cell array
% containing the name
if length(new_filelist) == 1
	new_filelist = new_filelist{1};
end
