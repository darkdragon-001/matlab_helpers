function y = joinfun(x,y0,f,varargin)
%JOINFUN Joins elements of x using function f
%   Parameters:
%   -   x: array with elements to join
%   -  y0: initial result
%   -   f: function which accepts two elements to join as parameters
%   - dim: dimension of x to work on
%
%   Examples:
%   - A=rand(3,3,2); mprod(A), mprod(A,3), mprod(A,3,false)
%   - A=rand(3,3,2); A=shiftdim(A,1); size(A)
%     joinfun(A,eye(3),@mtimes,2,true)
%     mprod(A,2,true)
%     squeeze(A(:,1,:))*squeeze(A(:,2,:))
%   - A=reshape(1:6,1,2,3);A=joinfun(A,zeros(1,0,3),@horzcat,1)
%   - A=reshape(1:6,1,2,3);A=joinfun(A,zeros(2,0,1),@horzcat,1,true)
%   - A=reshape(1:6,1,2,3);A=joinfun(A,zeros(1,0,3),@horzcat,2)
%   - A=reshape(1:6,1,2,3);A=joinfun(A,zeros(1,0,1),@horzcat,2,true)
%   - A=reshape(1:6,1,2,3);A=joinfun(A,zeros(1,0,1),@horzcat,3)
%   - A=reshape(1:6,1,2,3);A=joinfun(A,zeros(1,0,1),@horzcat,3,true)

% TODO add support for cell array: initialize with empty cell, unwrap cell within loop
% TODO make y0 optional, initialize with 0 for numeric arrays, empty cell for cell array

% Set dimension
if nargin > 3
    dim = varargin{1};
else
    % set to first nonsingleton dimension
    dim = find(size(x)~=1, 1);
    if isempty(dim), dim = 1; end
end
idim = ndims(x)-dim; % inverse dimension used for shifting backwards
nel = size(x,dim);   % number of elements in working dimension
% Set option to squeeze out singleton dimension dim of the result
if nargin > 4
    sq = varargin{2};
else
    sq = false;
end

% calculate number of elements per page
sz = size(x); sz(dim) = 1;
page = prod(sz); 

% shift dimensions so that working dimension is last
x = shiftdim(x,dim);
sz2 = circshift(sz,-dim,2); % same as following: sz=size(x);sz(end)=1;

% join
y = y0;
for i=1:nel
    % get current elements
    start = (i-1)*page+1;
    xx = x(start:start+page-1);       
    % reshape after linear indexing
    xx = reshape(xx, sz2);
    % shift dimensions back
    xx = shiftdim(xx, idim);
    % include singleton dimension "dim"
    if ~sq
        xx = reshape(xx, sz);
    end
    % join
    y = f(y,xx);
end

end

