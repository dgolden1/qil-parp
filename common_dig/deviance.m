function dev = deviance(mu, y)
% Calculate deviance in the same way as lassoglm
% dev = deviance(mu, y)
% 
% mu is the predicted value between 0 and 1
% y is the actual value, either 0 or 1

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id: deviance.m 217 2013-03-11 19:42:19Z dgolden $

% copied from lassoglm.m line 822
% lassoglm.m is kind of confusing, so I don't know if this formula is totally right

N = 1; % Number of "trials"; this should be 1
dev = 2*N.*(y.*log((y+(y==0))./mu) + (1-y).*log((1-y+(y==1))./(1-mu)));