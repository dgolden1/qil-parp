function feature_struct = GetAsStruct(obj)
% Return features as a Nx1 struct array, with one struct per patient
% and field names equal to feature names

feature_struct = struct('patient_id', obj.PatientIDs);

for pp = 1:length(obj.FeatureNames)
  this_fieldname = sanitize_struct_fieldname(obj.FeatureNames{pp});
  for nn = 1:length(obj.PatientIDs)
    feature_struct(nn).(this_fieldname) = obj.FeatureVector(nn,pp);
  end
end

