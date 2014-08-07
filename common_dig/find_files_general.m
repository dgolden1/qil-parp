function file_names = find_files_general(entry, directory, isRecursive)
% find_files_general - finds files with the specified entry in specified directory and 
% subdirectories (if recursive). 
% Arguments: entry - the string which must be included in the file names
%            directory - the directory specified by user
%            isRecursive - search subdirectories or not; 1 - yes; 0 - no;
% Returns:  a cell array with the fully specified file names
% Examples:
%    1. file_names = findfiles(entry, directory)
%       searches in the specified directory, not in subdirectories.
%    2. file_names = findfiles(entry, directory, 1)
%       searches in the specified directory and all its subdirectories.
% Notes:  
%    1. directory is complusory, use pwd for the current directory;
%    2. special entries:
%       if entry = '' then return all files
%       use entry = '.???' for extension matching, for example, '.txt'
%       use entry = '~???' for names not including '???'
%       entry is case sensitive
%    3. level limitation applies when recursive 

% Copyright (C) 2005 Bioeng Institute, University of Auckland
% Author: Xiang Lin, x.lin@auckland.ac.nz

% check inputs
if nargin < 2
    error('find_files_general.m: You must define entry and directory.');
elseif nargin == 2
    oldDir = pwd;
    if(~isdir(directory))
        error('find_files_general.m: No such directory found.');
    end;
    isRecursive = (1==0);
elseif nargin == 3
    oldDir = pwd;
    if(~isdir(directory))
        error('find_files_general.m: No such directory found.');
    end;
    if(~(isRecursive == 1))
        error('find_files_general.m: isRecursive = 1 if searching subdirectories wanted.');
    end;
    recurse = (1==1);
else
    error('find_files_general.m: No more than three inputs ');
end

d = dir(directory);

file_names = {};
numMatches = 0;
for i=1:length(d)
    
    a_name = d(i).name;
    a_dir = d(i).isdir;
    
    % if the file is not a directory, and there is at least one
    % occurence in the file name or entry = ''
    if(~a_dir & isempty(findstr('.lnk', a_name)))
        
        if(~isempty(findstr(entry,a_name)) | isempty(entry) | (strcmp(entry(1),'~') & isempty(findstr(entry(2:end),a_name))))
            % add the file name to the list.
            numMatches = numMatches + 1;
            file_names{numMatches} = fullfile(directory, a_name);
        end;
            
    % if recursive is required and the file is a directory but not '.', '..' and links
    elseif(isRecursive & a_dir & ~strcmp(a_name,'.') & ~strcmp(a_name,'..') & isempty(findstr('.lnk',a_name)))
        
        % solved link problem in windows, not sure in Linux
        file_names = [file_names find_files_general(entry, fullfile(directory,a_name), isRecursive)];
        numMatches = length(file_names);
        
    end
end 