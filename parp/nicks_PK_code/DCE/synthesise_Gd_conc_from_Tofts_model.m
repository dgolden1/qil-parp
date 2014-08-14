function Gd_conc_signals = synthesise_Gd_conc_from_Tofts_model(PK_params_pairs, PK_params_type, time_vec, AIF_onset_time, Gd_dose, varargin)

% Function originally by Nick Hughes
% Modified by Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

% Check that PK_params_pairs is of the correct size
if size(PK_params_pairs,2) ~= 2
  error('%s: PK_params_pairs should have two columns (with rows for each possible pair combination)', mfilename);
end

% Get vectors of Ktrans and kep values for all PK param pair combinations
switch PK_params_type
 case 'Ktrans ve'
  Ktrans_vec = PK_params_pairs(:,1);
  kep_vec = PK_params_pairs(:,1)./PK_params_pairs(:,2);
 case 'Ktrans kep'
  Ktrans_vec = PK_params_pairs(:,1);
  kep_vec = PK_params_pairs(:,2);
 otherwise
  error('Unknown PK params type: %s', PK_params_type);
end

% Check PK params are within a sensible range
invalid_Ktrans_idx = find((Ktrans_vec < 0) | isnan(Ktrans_vec) | isinf(Ktrans_vec));
invalid_kep_idx = find((kep_vec < 0) | isnan(kep_vec) | isinf(kep_vec));

if ~isempty(invalid_Ktrans_idx)
  error('Invalid Ktrans values passed to %s\nSetting Gd_conc signal to zero for these values', mfilename);
end

if ~isempty(invalid_kep_idx)
  error('Invalid kep values passed to %s:\nSetting Gd_conc signal to zero for these values', mfilename);
end

% Check if AIF parameters passed in
if length(varargin) == 2
  a = varargin{1};
  m = varargin{2};
else
  % Used std Weinmann params for AIF (as used in Tofts model)
  a = [3.99 4.78];
  m = [0.114 0.0111];
end


% Check that time vector is strictly monotonic
if ~all(diff(time_vec) > 0)
  error('Time vector should be stricly monotonic');
end

% Reshape time vector into a row vector
% NB: times should be in units of minutes
time_vec = time_vec(:)';
T = length(time_vec);

% Check that the AIF onset time is valid
if time_vec(end) <= AIF_onset_time
  error('AIF onset time (%1.2f) occurs on or after the last time point (%1.2f)', AIF_onset_time, time_vec(end));
end

if time_vec(1) > AIF_onset_time
  error('AIF onset time (%1.2f) occurs before the first time point (%1.2f)', AIF_onset_time, time_vec(1));
end

% Set up a relative time vector containing time samples relative to the AIF onset time (rather than the start of the MRI acquisition)
% First we get an index into the sample time vector corresponding to the AIF onset time
AIF_onset_time_idx = length(find(time_vec <= AIF_onset_time));

% Now we compute the relative time vector by subtracting the AIF onset time
relative_time_vec = time_vec - time_vec(AIF_onset_time_idx);
relative_time_vec(1:AIF_onset_time_idx-1) = 0;


% Generate an N x T matrix of Ktrans values (replicated across columns t)
Ktrans_matrix = repmat(Ktrans_vec, 1, T);

% Generate matrices we will need for computation of Gd_conc signal 
kep_t_matrix = kep_vec * relative_time_vec;
m1_t_matrix = repmat(m(1) * relative_time_vec, size(kep_t_matrix,1), 1);
m2_t_matrix = repmat(m(2) * relative_time_vec, size(kep_t_matrix,1), 1);

m1_minus_kep_matrix = repmat(m(1) - kep_vec, 1, T);
m2_minus_kep_matrix = repmat(m(2) - kep_vec, 1, T);

% Set any zeros to eps so that we don't get divide by zero errors
m1_minus_kep_matrix(m1_minus_kep_matrix==0) = eps;
m2_minus_kep_matrix(m2_minus_kep_matrix==0) = eps;

% Compute each of the two terms needed in the Tofts model summation
sum_term_one = a(1) * (exp(-1*kep_t_matrix)-exp(-1*m1_t_matrix))./m1_minus_kep_matrix;
sum_term_two = a(2) * (exp(-1*kep_t_matrix)-exp(-1*m2_t_matrix))./m2_minus_kep_matrix;

% Now compute the Gd_conc signal for every (Ktrans,ve) pair
Gd_conc_signals = Gd_dose * Ktrans_matrix .* (sum_term_one + sum_term_two);

% Set Gd conc signals to zero where the Ktrans or kep param used was invalid
Gd_conc_signals(invalid_Ktrans_idx,:) = 0;
Gd_conc_signals(invalid_kep_idx,:) = 0;

% Finally set Gd conc to zero if it is NaNs
Gd_conc_signals(isnan(Gd_conc_signals)) = 0;

1;
