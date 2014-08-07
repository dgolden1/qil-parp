function fix_figure

MAX_ATTEMPTS = 5;

persistent fix_attempt
if isempty(fix_attempt)
	fix_attempt = 1;
end
	
h = gcf;
saveas(h, '~/temp/junk.fig');
h2 = open('~/temp/junk.fig');
close(h);

pos = get(h2, 'position');
% if any(pos < 0)
% 	if fix_attempt >= MAX_ATTEMPTS
% 		clear fix_attempt;
% 		error('Unable to fix figure in %d iterations', fix_attempt)
% 	end
% 
% 	fix_attempt = fix_attempt + 1;
% 	fix_figure;
% else
% 	clear fix_attempt;
% 	figure(h2);
% end
