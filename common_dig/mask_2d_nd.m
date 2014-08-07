function varargout = mask_2d_nd(img_nd, mask)
% Replicate a 2D mask to be applied to an image which may have more than two dimensions
% [mask_rep, img_masked, img_masked_keep_shape] = mask_2d_nd(img_nd, mask)
% 
% INPUTS
% img_nd: MxNxRx... image stack
% mask: MxN mask
% 
% OUTPUTS
% mask_rep: a new mask with the same dimensions as img_nd
% img_masked: the mask applied to img_nd as a sum(mask(:))x1 vector
% img_masked_keep_shape: reshaped version of img_masked with the first
%  dimension of length sum(mask(:)) and dimensions 2:P equal to img_nd
%  dimensions 3:P+1

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id: mask_2d_nd.m 244 2013-04-18 00:07:53Z dgolden $

if ~(size(img_nd, 1) == size(mask, 1) && size(img_nd, 2) == size(mask, 2) && ismatrix(mask))
  error('Mask must be a NxM matrix with size equal to the first two dimensions of img_nd');
end

mask_rep_size = size(img_nd);
mask_rep_size(1:2) = 1;
if length(mask_rep_size) < 3
  mask_rep_size(3) = 1;
end

if nargout > 0
  varargout{1} = repmat(mask, mask_rep_size);
end
if nargout > 1
  varargout{2} = img_nd(varargout{1});
end
if nargout > 2
  varargout{3} = reshape(varargout{2}, [sum(mask(:)) mask_rep_size(3:end)]);
end
