function [n_eff_mean, n_eff_var] = effective_data_size(x)
% Find effective x size of 1st order autoregressive AR(1) signal
% [n_eff_mean, n_eff_var] = effective_data_size(x)
% 
% For "effective data size", see Mudelsee (2010)
% doi:10.1007/978-90-481-9482-7, chapter 2, equations (2.7) (mean) and
% (2.35) (variance)
% 
% This is based on Bayley and Hammersley (1946),
% http://www.jstor.org/stable/2983560

% By Daniel Golden (dgolden1 at stanford dot edu) November 2011
% $Id: effective_data_size.m 2 2012-08-02 23:59:40Z dgolden $

n = length(x);

% AR(1) coefficient
a = abs(corr(x(1:end-1), x(2:end)));

% Effective n, for mean; see [Mudelsee, 2010, Eq. 2.7]
n_eff_mean = n.*(1 + 2./n.*(1/(1-a)).*(a*(n - 1/(1-a)) - a.^n*(1 - 1/(1-a)))).^(-1);

% Effective n for variance; see [Mudelsee, 2010, Eq. 2.35]
n_eff_var = n.*(1 + 2./n.*(1/(1-a^2)).*(a^2*(n - 1/(1-a^2)) - a.^(2*n)*(1 - 1/(1-a^2)))).^(-1);
