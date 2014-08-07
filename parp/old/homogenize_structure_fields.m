function [struct1_common, struct2_common] = homogenize_structure_fields(struct1, struct2)
% Take two dissimilar structures and make them similar by creating missing
% fields and setting them equal to []
% [struct1_common, struct2_common] = homogenize_structure_fields(struct1, struct2)

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

fn1 = fieldnames(struct1);
fn2 = fieldnames(struct2);

struct1_missing_fields = fn2(~ismember(fn2, fn1));
struct2_missing_fields = fn1(~ismember(fn1, fn2));

struct1_common = struct1;
struct2_common = struct2;
for kk = 1:length(struct1_missing_fields)
  struct1_common(1).(struct1_missing_fields{kk}) = [];
end
for kk = 1:length(struct2_missing_fields)
  struct2_common(1).(struct2_missing_fields{kk}) = [];
end

% If the structures were empty before, the preceding code makes them 1x1.
% Make them empty again, if necessary
if isempty(struct1)
  struct1_common(1) = [];
end
if isempty(struct2)
  struct2_common(1) = [];
end

1;
