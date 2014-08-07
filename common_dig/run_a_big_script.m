function run_a_big_script(run_cmd)
% Run a big script and e-mail me if it generates an error

% By Daniel Golden (dgolden1 at stanford dot edu) October 2009
% $Id: run_a_big_script.m 2 2012-08-02 23:59:40Z dgolden $

%% Setup
my_email = 'dgolden1@stanford.edu';

setpref('Internet', 'E_mail', my_email);
setpref('Internet', 'SMTP_Server', 'smtp.stanford.edu'); 

[stat, hostname] = unix('hostname');
hostname = strrep(hostname, sprintf('\n'), ''); % Remove newline

if ~exist('run_cmd', 'var') || isempty(run_cmd) || ~ischar(run_cmd)
  error('run_cmd must be a string');
end

%% Run
t_start = now;
try
  disp(sprintf('run_a_big_script: run of %s started at %s', run_cmd, datestr(t_start)))
  eval(run_cmd);
catch er
  % Sometimes hostname regains its newline for some crazy reason
  hostname = strrep(hostname, sprintf('\n'), ''); % Remove newline
  
  mail_text = sprintf('MATLAB error running %s on %s at %s\n\n%s', run_cmd, hostname, datestr(now), ...
    getReport(er, 'basic', 'hyperlinks', 'off'));
  mail_subject = sprintf('[MATLAB Output] error running %s on %s', run_cmd, hostname);
  send_email(my_email, mail_subject, mail_text);

  rethrow(er);
end

t_end = now;

% Sometimes hostname regains its newline for some crazy reason
hostname = strrep(hostname, sprintf('\n'), ''); % Remove newline
  
mail_subject = sprintf('[MATLAB Output] successfully completed %s on %s', run_cmd, hostname);
mail_text = sprintf('MATLAB successfully completed %s on %s at %s. Total run time = %s.', ...
  run_cmd, hostname, datestr(now), time_elapsed(t_start, t_end));
send_email(my_email, mail_subject, mail_text);

function send_email(address, subject, body)

% Matlab's sendmail utlitity mysteriously stopped working on the data server
% around Aug 29, 2010
if ispc
  sendmail(address, subject, body);
else
  unix(sprintf('echo ''%s'' | mail -s "%s" %s', body, subject, address));
end

