function progress_temp_dirname = parfor_progress_init
% progress_temp_dirname = parfor_progress_init
% 
% Function to set up a temporary directory to keep track of iterations of a
% parfor loop
% 
% See also parfor_progress_step and parfor_progress_cleanup
% 
% Use it like this:
% 
% progress_temp_dirname = parfor_progress_init;
% parfor kk = 1:N
%  t_start = now;
%  blah blah;
%  iteration_number = parfor_progress_step(progress_temp_dirname, kk);
%  fprintf('Processed thing %d of %d in %s\n', iteration_number, N, time_elapsed(t_start, now));
% end
% parfor_progress_cleanup(progress_temp_dirname);

% By Daniel Golden (dgolden1 at stanford dot edu) January 2010
% $Id: parfor_progress_init.m 208 2013-03-05 19:49:25Z dgolden $

temp_dir = tempdir;

DIR_MAX = 100;
d = dir(fullfile(temp_dir, 'parfor_progress_*'));
if length(d) == DIR_MAX
	error('Exceeded allowable number of temporary random directories (%d) in %s', DIR_MAX, temp_dir);
end

b_made_dir = false;
for kk = 1:DIR_MAX
	progress_temp_dirname = fullfile(temp_dir, sprintf('parfor_progress_%04d', kk));
	if exist(progress_temp_dirname, 'dir')
		continue;
	else
		[stat, message] = mkdir(progress_temp_dirname);
		if stat ~= 1
			error('Error creating %s: %s', progress_temp_dirname, message);
		end
		b_made_dir = true;
		break;
	end
end

if ~b_made_dir
	error('Unable to create temporary directory in %s', temp_dir);
end
