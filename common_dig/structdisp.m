function structdisp(Xname, maxdepth)
% function structdisp Xname
% function structdisp(X)
%---
% Recursively display the content of a structure and its sub-structures
%
% Input:
% - Xname/X     one can give as argument either the structure to display or
%               or a string (the name in the current workspace of the
%               structure to display)
%
% A few parameters can be adjusted inside the m file to determine when
% arrays and cell should be displayed completely or not

% Thomas Deneux
% Copyright 2005-2012

% Modified by Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id: structdisp.m 162 2013-01-29 00:18:57Z dgolden $

if ischar(Xname)
    X = evalin('caller',Xname);
else
    X = Xname;
    Xname = inputname(1);
end

if ~isstruct(X), error('argument should be a structure or the name of a structure'), end

if ~exist('maxdepth', 'var') || isempty(maxdepth)
  maxdepth = inf;
end

depth = 0;
rec_structdisp(Xname,X,depth,maxdepth)

%---------------------------------
function rec_structdisp(Xname,X,depth,maxdepth)
%---

depth = depth + 1;

if depth > maxdepth
  fprintf('Reached max recursion depth (%d)\n', maxdepth);
  return;
end

%-- PARAMETERS (Edit this) --%

ARRAYMAXROWS = 10;
ARRAYMAXCOLS = 10;
ARRAYMAXELEMS = 30;
CELLMAXROWS = 10;
CELLMAXCOLS = 10;
CELLMAXELEMS = 30;
CELLRECURSIVE = false;

%----- PARAMETERS END -------%

disp([Xname ':'])
%fprintf('\b')

if isstruct(X) || isobject(X)
    F = fieldnames(X);
    
    % Kludge for DICOM-RT files; if substructs are Item_1, Item_2, etc, then just choose
    % the first item
    item_idx = find(~cellfun(@isempty, regexp(F, '^Item_\d+$', 'once')));
    if length(item_idx) > 1
      % Delete all Item_XXX substructs after the first
      X = rmfield(X, F(item_idx(2:end)));
      F(item_idx(2:end)) = [];
      fprintf('[Additional Item_XXX fields removed of %d total]\n', length(item_idx));
    end
    
    disp(X)
    
    nsub = length(F);
    Y = cell(1,nsub);
    subnames = cell(1,nsub);
    for i=1:nsub
        f = F{i};
        Y{i} = X.(f);
        subnames{i} = [Xname '.' f];
    end
elseif CELLRECURSIVE && iscell(X)
    disp(X)
    nsub = numel(X);
    s = size(X);
    Y = X(:);
    subnames = cell(1,nsub);
    for i=1:nsub
        inds = s;
        globind = i-1;
        for k=1:length(s)
            inds(k) = 1+mod(globind,s(k));
            globind = floor(globind/s(k));
        end
        subnames{i} = [Xname '{' num2str(inds,'%i,')];
        subnames{i}(end) = '}';
    end
else
    return
end

for i=1:nsub
    a = Y{i};
    if isstruct(a) || isobject(a)
        if length(a)==1
            rec_structdisp(subnames{i},a,depth,maxdepth)
        else
            for k=1:length(a)
                rec_structdisp([subnames{i} '(' num2str(k) ')'],a(k),depth,maxdepth)
            end
        end
    elseif iscell(a)
        if size(a,1)<=CELLMAXROWS && size(a,2)<=CELLMAXCOLS && numel(a)<=CELLMAXELEMS
            rec_structdisp(subnames{i},a,depth,maxdepth)
        end
%     elseif size(a,1)<=ARRAYMAXROWS && size(a,2)<=ARRAYMAXCOLS && numel(a)<=ARRAYMAXELEMS
%         disp([subnames{i} ':'])
%         disp(a)
    end
end
