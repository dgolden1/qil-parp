function [R1, R2] = get_CA_relaxivities(CA_type, MR_field_strength, log_file, log_window_handle)

R1 = []; R2 = [];

if nargin == 1
	disp(sprintf('%s: missing MR_field_strength (should be the second argument passed', mfilename));
	return;
elseif nargin == 2
	log_file = [];
	log_window_handle = [];
elseif nargin == 3
	log_window_handle = [];
end

CA_type = lower(CA_type);


if MR_field_strength == 1.5
	% See here for alternative values...
	% Invest Radiol. 2006 Mar;41(3):213-21.
	% Relaxivity of Gadopentetate Dimeglumine (Magnevist), Gadobutrol (Gadovist), and Gadobenate Dimeglumine (MultiHance) in human blood plasma at 0.2, 1.5, and 3 Tesla.
	% Pintaske J, Martirosian P, Graf H, Erb G, Lodemann KP, Claussen CD, Schick F.
	switch CA_type
 		case 'prohance'
  		R1 = 4.5;
  		R2 = 5.5;
 		case 'omniscan'
  		% http://www.pom.go.id/io/monograf/Omniscan.html
  		R1 = 4.6;
  		R2 = 5.1;
 		case 'magnevist'
  		R1 = 3.9; % Values from Pintaske et al., 2006, Table 2, dx.doi.org/10.1097/01.rli.0000197668.44926.f7
  		R2 = 5.3;
      % R1 = 4.3; % Nick's original values
      % R2 = 4.4;
 		otherwise
  		error('Unknown contrast agent type: %s or no relaxivity data at %0.1fT', CA_type, MR_field_strength);
  end
elseif MR_field_strength == 3.0
  switch CA_type
    case 'magnevist'
      % See Pintaske et al., 2006, Table 2, dx.doi.org/10.1097/01.rli.0000197668.44926.f7
      R1 = 3.3;
      R2 = 5.2;
    otherwise
      error('Unknown contrast agent type: %s or no relaxivity data at %0.1fT', CA_type, MR_field_strength);
  end
elseif MR_field_strength == 7.0
	switch CA_type
		case 'magnevist'
			% Invest Radiol. 2010 Sep;45(9):554-8.
			% Gadolinium-based magnetic resonance contrast agents at 7 Tesla: in vitro T1 relaxivities in human blood plasma.
			% Noebauer-Huhmann IM, Szomolanyi P, Juras V, Kraff O, Ladd ME, Trattnig S.
			R1 = 3.3;
			
			disp(sprintf('%s - do not have an explicit R2 relaxivity for Magnevist at 7T. Using value at 1.5T...', mfilename));
			R2 = 4.4;
			
		otherwise
			error('Unknown contrast agent type: %s or no relaxivity data at this field strength', CA_type);
	end
else
	error(sprintf('No relaxivity data for field strength of %1.1f T', MR_field_strength));
end
