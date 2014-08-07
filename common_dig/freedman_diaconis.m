function numbins = freedman_diaconis(data)
% Freedman-Diaconis' choice for number of bins in a histogram
% numbins = freedman_diaconis(data)
% 
% This is the default rule in the Matlab distribution fitting tool
% (dfittool)
% 
% See http://en.wikipedia.org/wiki/Histogram#Number_of_bins_and_width

% By Daniel Golden (dgolden1 at stanford dot edu) December 2011
% $Id: freedman_diaconis.m 334 2013-07-09 19:17:38Z dgolden $

if ~isvector(data)
  error('data must be a vector');
end

binwidth = 2*diff(quantile(data, [0.25 0.75]))/length(data).^(1/3);
numbins = round(range(data)/binwidth);
