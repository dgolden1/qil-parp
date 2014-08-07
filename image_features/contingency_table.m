function varargout = contingency_table(X, Y, b_print)
% Make a contingency table from the categorical X and Y
% cont_tab = contingency_table(X, Y, b_print)
% 
% Only a 2x2 table is supported for now
% X is Nx1 logical
% Y is Nx1 logical
% 
% Output contingency table:
% 
%  ---------------------
% |  X & Y   |  ~X & Y  |
%  ---------------------
% |  X & ~Y  | ~X & ~Y  |
%  ---------------------
% 
% See also: crosstab

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id: contingency_table.m 339 2013-07-11 00:06:11Z dgolden $

%% Setup
if ~exist('b_print', 'var') || isempty(b_print)
  b_print = false;
end

if ~isequal(unique(X(:)), [0 1].')
  error('X must consist only of 0s and 1s');
end
if ~isequal(unique(Y(:)), [0 1].')
  error('Y must consist only of 0s and 1s');
end

%% Make table
cont_tab = nan(2);
cont_tab(1,1) = sum(X & Y);
cont_tab(1,2) = sum(~X & Y);
cont_tab(2,1) = sum(X & ~Y);
cont_tab(2,2) = sum(~X & ~Y);

%% Set output arguments
if nargout > 0
  varargout{1} = cont_tab;
end

%% Print table
if b_print
  fprintf('% 5s % 5s % 7s % 7s\n', '', 'X', '~X', 'total');
  fprintf('% 5s % 5d % 7d % 7d\n', 'Y', cont_tab(1,1), cont_tab(1,2), sum(cont_tab(1,:)));
  fprintf('% 5s % 5d % 7d % 7d\n', '~Y', cont_tab(2,1), cont_tab(2,2), sum(cont_tab(2,:)));
  fprintf('% 5s % 5d % 7d % 7d\n', 'total', sum(cont_tab(:,1)), sum(cont_tab(:,2)), sum(cont_tab(:)));
end
