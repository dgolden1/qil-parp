function [h, pval] = prop_diff_test(successes1, successes2)
% Evaluate the difference between the two proportions
% Inputs are boolean vectors where a 1 represents a success
% 
% Adapted from Chapter 6.6 of Navidi 2008 "Statistics for Engineers and
% Scientists" except that I use the Student's t distribution instead of the
% normal distribution to allow for small sample sizes

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

error('Actually, I don''t think this will work -- try Fisher''s exact test');
