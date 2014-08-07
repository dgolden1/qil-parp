function [mean, pm] = agresti_coull(n, x, alpha)
% [mean, pm] = agresti_coull(n, x, alpha)
% Agresti-coull confidence interval for binomial-distributed data.
% 
% INPUTS
% n: number of trials
% x: number of successes
% alpha: fractional level for confidence interval.  I.e., for the
% "5-percent" level, use alpha = 0.05 (the default).
% 
% OUTPUTS
% mean: mean value
% pm: plus or minus this value (width of confidence interval is 2*pm)
%
% See
% http://en.wikipedia.org/w/index.php?title=Binomial_proportion_confidence_interval&oldid=379853218#Agresti-Coull_Interval (which I wrote!)

% By Daniel Golden (dgolden1 at stanford dot edu) September 2010
% $Id: agresti_coull.m 2 2012-08-02 23:59:40Z dgolden $

if ~exist('alpha', 'var') || isempty(alpha)
  alpha = 0.05;
end

z = norminv(1 - alpha/2);

nt = n + z^2;
pt = (x + z^2/2)./nt;

mean = pt;
pm = z.*sqrt(pt.*(1-pt)./nt);
