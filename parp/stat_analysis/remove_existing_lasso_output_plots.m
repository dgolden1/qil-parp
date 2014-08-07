function remove_existing_lasso_output_plots(output_dir)
% Remove lasso plots from output directory

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

d = dir(fullfile(output_dir, '*.png'));
for kk = 1:length(d)
  delete(fullfile(output_dir, d(kk).name));
end
% if ~isempty(d)
%   fprintf('Removed %d files(s) from %s\n', length(d), output_dir);
% end
