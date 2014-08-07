function t_str = time_elapsed(t_start, t_end)
% t_str = time_elapsed(t_start, t_end)
% Returns string with elapsed time in "natural" format (e.g., N hours, N
% min, N sec, etc)
% 
% Ex:
% t_start = now;
% ... run some stuff ...
% fprintf('Finished running stuff in %s\n', time_elapsed(t_start, now));

% By Daniel Golden (dgolden1 at stanford dot edu) September 2009
% $Id: time_elapsed.m 13 2012-08-10 19:30:42Z dgolden $

t_diff = abs(t_end - t_start);
days = floor(t_diff);
hours = floor(fpart(t_diff)*24);
min = floor(fpart(fpart(t_diff)*24)*60);
sec = fpart(fpart(fpart(t_diff)*24)*60)*60;

if t_end > t_start
	t_str = '';
else
	t_str = '- ';
end

if t_diff >= 1
	t_str = [t_str sprintf('%d days, ', days)];
end
if t_diff >= 1/24
	t_str = [t_str sprintf('%d hours, ', hours)];
end
if t_diff >= 1/1440
	t_str = [t_str sprintf('%d min, ', min)];
end

if t_diff >= 10/86400
	t_str = [t_str sprintf('%0.0f sec', sec)];
else
	t_str = [t_str sprintf('%0.2f sec', sec)];
end
