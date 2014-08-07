function parfor_progress_cleanup(progress_temp_dirname)
% parfor_progress_cleanup(progress_temp_dirname)
% 
% Function to clean up a temporary directory to keep track of iterations of a
% parfor loop
% 
% See also parfor_progress_init and parfor_progress_step
% 
% Use it like this:
% 
% progress_temp_dirname = parfor_progress_init;
% parfor kk = 1:N
%  t_start = now;
%  blah blah;
%  iteration_number = parfor_progress_step(progress_temp_dirname, kk);
%  disp(sprintf('Processed thing %d of %d in %s', iteration_number, N, time_elapsed(t_start, now)));
% end
% parfor_progress_cleanup(progress_temp_dirname);

% By Daniel Golden (dgolden1 at stanford dot edu) January 2010
% $Id: parfor_progress_cleanup.m 2 2012-08-02 23:59:40Z dgolden $

[stat, message] = rmdir(progress_temp_dirname, 's');

if stat ~= 1
	error('Error removing temporary directory %s: %s', progress_temp_dirname, message);
end
