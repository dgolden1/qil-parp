function iteration_number = parfor_progress_step(progress_temp_dirname, loop_counter)
% iteration_number = parfor_progress_step(progress_temp_dirname,
% loop_counter)
% 
% Function to write to a temporary directory to keep track of iterations of a
% parfor loop
% 
% See also parfor_progress_init and parfor_progress_cleanup
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
% $Id: parfor_progress_step.m 209 2013-03-05 23:45:20Z dgolden $

if isunix
  system(sprintf('touch %s', fullfile(progress_temp_dirname, num2str(loop_counter, '%08d'))));
elseif ispc
  system(sprintf('echo.>%s', fullfile(progress_temp_dirname, num2str(loop_counter, '%08d'))));
else
  error('Unsupported platform: %s', computer);
end
d = dir(progress_temp_dirname);
iteration_number = length(d) - 2; % Exclude . and .. directories
