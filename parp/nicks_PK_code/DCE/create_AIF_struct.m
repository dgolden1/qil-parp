
function AIF_Struct = create_AIF_struct(AIF_type)

% Biexponential AIF Parameters:
%
% AIF type: a_{1}, m_{1}, a_{2}, m_{2}
% Weinmann: 3.99, 0.144, 4.78, 0.011
% Fritz-Hansen: 24, 3.0, 6.2, 0.016
% Modified F-H: 36, 4.9, 13, 0.08
% Femoral: 92, 5.3, 6.4, 0.016
% Orton: 11.14, 20.2, 15.1, 0.08 [Orton's AIF is similar to Geoff Parker's population based AIF.]

switch lower(AIF_type)
 case {'weinmann', 'w'}
  a = [3.99 4.78];
  m = [0.144 0.011];
  name = 'weinmann';
 case {'fritz-hansen', 'f-h', 'fh'}
  a = [24 6.2];
  m = [3.0 0.016];
  name = 'fritz-hansen';
 case {'modified fritz-hansen', 'modified f-h', 'mf-h', 'mfh'}
  a = [36 13];
  m = [4.9 0.08];
  name = 'modified fritz-hansen';
 case 'femoral'
  a = [92 6.4];
  m = [5.3 0.016];
  name = 'femoral';
 case 'orton'
  a = [11.14 15.1];
  m = [20.2 0.08];
  name = 'orton';
 otherwise
  disp(sprintf('Unknown AIF type: %s', AIF_type));
  AIF_Struct = [];
  return;
end

AIF_Struct.a = a;
AIF_Struct.m = m;
AIF_Struct.name = name;

t = [0:(5.2/60):8]'; T = length(t);
AIF = sum(repmat(a,T,1).*exp(-t*m),2);
plot(t, AIF, 'bo-');
xlabel time(mins);
ylabel C(t)
title(sprintf('%s AIF', AIF_type));
ylim = get(gca, 'YLim');
set(gca, 'YLim', [0 ylim(2)]);
