function [y_hat, rms_error, r] = run_model_regress(x, b, y)
% Run a multiple regression model
% [y_hat, rms_error, r] = run_model_regress(x, b, y)

% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id$

y_hat = [ones(size(x, 1), 1) x]*b;

y_hat = max(0, y_hat); % Clip RCB so it's not less than 0

if nargout > 1
  rms_error = sqrt(mean((y - y_hat).^2));
end
if nargout > 2
  r = corr(y, y_hat);
end
