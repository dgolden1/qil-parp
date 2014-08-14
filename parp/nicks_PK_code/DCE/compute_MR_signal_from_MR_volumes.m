
function signal_matrix = compute_MR_signal_from_MR_volumes(DCE_MRI_Struct, voxel_idx)

% Setup MR signal matrix
num_signal_volumes = length(DCE_MRI_Struct.Data);
signal_matrix = zeros(length(voxel_idx), num_signal_volumes);

% Extract signal values
for v=1:num_signal_volumes
  signal_vol = DCE_MRI_Struct.Data{v};
  signal_matrix(:,v) = signal_vol(voxel_idx);
end
