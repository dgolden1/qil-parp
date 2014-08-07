function r = nancorr(x, y)
% Function: Correlation coefficient, excluding invalid values

% By Daniel Golden (dgolden1 at stanford dot edu) March 2012
% $Id: nancorr.m 2 2012-08-02 23:59:40Z dgolden $

idx_valid = isfinite(x(:)) & isfinite(y(:));

r = corr(x(idx_valid), y(idx_valid));
