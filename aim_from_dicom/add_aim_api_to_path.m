function add_aim_api_to_path(path_to_aim_api)
% Add AIM API to Java path
% add_aim_api_to_path(path_to_aim_api)
% 
% Get AIM API from http://www.stanford.edu/group/qil/cgi-bin/mediawiki/index.php/AIM_API

% By Daniel Golden (dgolden1 at stanford dot edu) March 2013
% $Id$

javaaddpath(fullfile(path_to_aim_api, 'AIMv3API.jar'));
javaaddpath(fullfile(path_to_aim_api, 'Org.restlet.jar'));
clear java;
