function enhancement_matrix = compute_MR_enhancement_from_MR_signal(signal_matrix, AIF_onset_time_idx)

% Function originally by Nick Hughes
% Modified by Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

if isempty(signal_matrix)
	error('empty signal matrix passed...');
end

[N,T] = size(signal_matrix);

if ~exist('AIF_onset_time_idx', 'var') || isempty(AIF_onset_time_idx)
  error('AIF_onset_time_idx is empty');
  % AIF_onset_time_idx = 2;
end

if AIF_onset_time_idx <= 1
  error('CA injection time index variable (%d) occurs <= the first time sample, i.e. no pre-contrast baseline volumes...', AIF_onset_time_idx);
end

if AIF_onset_time_idx >= T
  error('CA injection time index variable (%d) occurs >= the last time sample, no post-contrast volumes...', AIF_onset_time_idx);
end

baseline_signal_vec = mean(signal_matrix(:,1:AIF_onset_time_idx-1),2);
baseline_signal_matrix = repmat(baseline_signal_vec, 1, T);

enhancement_matrix = (signal_matrix./baseline_signal_matrix) - 1;
