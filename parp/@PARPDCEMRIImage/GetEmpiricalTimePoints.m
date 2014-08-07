function [t1, t2, t3, b_high_t_res] = GetEmpiricalTimePoints(obj)
% Get t1, t2 and t3 for empirical parameters

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

% OLD VALUES
% t1 = contrast_injection_time; % Time of injection, sec
% t2 = t1 + 33; % Time midpoint (where plateau may begin, sec)
% t3 = min(t1 + 180, max(obj.Time)); % End time (sec)

med_dt = median(diff(obj.Time));
b_high_t_res = med_dt < 30;

contrast_injection_time = GetContrastInfo(obj);
t1 = contrast_injection_time; % Time of injection, sec
t2 = max(t1 + 110, obj.Time(2)); % Time midpoint (approx time of max contrast)
t3 = max(obj.Time(obj.Time < t1 + 1200)); % End time (sec)

if (t2 - t1 < 30 && b_high_t_res) || (t3 - t2 < 60 && b_high_t_res)
  error('3TP time spacing is too narrow');
end
