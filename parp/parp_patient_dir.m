function d_out = parp_patient_dir
% Give path to PARP patient directory based on hostname

% If we did this once, don't do it again
persistent d
if ~isempty(d)
  d_out = d;
  return;
end

% Choose directory
[~, hostname] = system('hostname');
hostname = hostname(1:end-1); % ditch \n

switch hostname
  case 'dantop.local'
    d = '/Users/dgolden/Documents/qil/parp_patient_data';
  case 'quadcoredan.stanford.edu'
    d = '/home/dgolden/parp/parp_patient_data';
  case 'goldenmac.stanford.edu'
    d = '/Users/dgolden/Documents/qil/parp_patient_data';
  otherwise
    error('Unknown hostname %s', hostname);
%     d = uigetdir(pwd, 'Choose directory containing PARP data files');
%     if isempty(d)
%       return;
%     end
end

d_out = d;
