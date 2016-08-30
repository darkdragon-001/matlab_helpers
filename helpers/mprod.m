function B = mprod(A,varargin)
%MPROD Matrix product of array elements
%   Calculate matrix product of all pages of 3D array A along dimension dim.
%   Analog to times/prod for element-wise operations, mtimes/mprod work for matrices.
%
%   Parameters (* optional):
%   -   A: Must have three dimensions where all dimensions other than "dim"
%          need to have the same size. 
%          For example for dim=3 size(A)=[m,m,n], for dim=2 size(A)=[m,n,m].
%   * dim: Working dimension. Defaults to last non-singleton dimension.
%   *  sq: If set to true, dimension dim is squeezed out.
%          For example for dim=2 size(B)=[m,m] instead of size(B)=[m,1,m]
%
%   Examples:
%   - A=rand(3,3,2); 
%     mprod(A)
%     mprod(A,3)
%     mprod(A,3,false)
%   - A=rand(3,3,2); A=shiftdim(A,1);
%     mprod(A,2,true)
%     squeeze(A(:,1,:))*squeeze(A(:,2,:))
%     joinfun(A,eye(3),@mtimes,2,true)

% NOTE same as joinfun(A,eye(size(A,n)),@mtimes,dim)

% Set dimension
if nargin > 1
    %dim = mod(varargin{1},3);
    dim = varargin{1};
    if dim > 3
        error('Invalid working dimension selected.');
    end
else
    % set to last nonsingleton dimension
    dim = find(size(A)~=1, 1, 'last');
    if isempty(dim), dim = 1; end
end
% Set option to squeeze out singleton dimension dim of the result
if nargin > 2
    sq = varargin{2};
else
    sq = false;
end
% Check A
if ndims(A)>3
    error('Invalid geometry of matrix A: Too many dimensions.');
end
sz = size(A); sz(dim) = [];
if sz(1)~=sz(2) % NOTE alternatives: all(sz==sz(1)) or range(sz)==0
    error('Invalid geometry of matrix A: Not array of square matrices.');
end

% final size
sz = size(A); sz(dim) = 1;

% shift dimensions so that working dimension is last
A = shiftdim(A,dim);

% Calculate matrix product
B = eye(size(A,1));
for i=1:size(A,ndims(A)) % for all elements in dimension dim (which is shifted to end)
    % shift dimensions back to original shape
    % NOTE same as: A(:,:,i) = shiftdim(A(:,:,i),ndims(A)-dim)
    if mod(dim,2)==0
        A(:,:,i) = A(:,:,i).';
    end
    % calculate
    B = B * A(:,:,i);
end

% Squeeze out joined dimension "dim" if sq==true
if ~sq
    B = reshape(B,sz);
end

end

