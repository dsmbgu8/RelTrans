function Xr = relK(X,C,metric)
% Input:
%  X = [NX x d] matrix of input vectors
%  C = [NC x d] matrix of correspondences
%  metric = distance metric: Euclidean (default), EuclideanSquared, 
%           RBF, RBFSumNorm
% Output:
%  Xr = [NX x NC] matrix of input vectors in relational space
%       w.r.t. correspondences C and distance metric d

if ~exist('metric','var')
   metric='Euclidean';
end

% Notes:
% Euclidean often best option for linearly xformed feature spaces
% RBF often best option for similar feature spaces!

d = fast_dmtx(X',C');
zerov = find(d==0);
negv = find(d<0);
if sum(negv(:)) > 0
  %disp('relK error: sqeuc dist < 0')
  d(negv) = 0;
  %negvals = d(negv);
  %negvals(:)
end

if strcmp(metric,'RBF')
  Xr = exp(-d);
  Xr = sumnorm(Xr); % sum-row normalize
elseif strcmp(metric,'RBFSumNorm')
  Xr = exp(-sumnorm(d));
elseif strcmp(metric,'EuclideanSquared')
  Xr = sumnorm(d); % sum-row normalize
elseif strcmp(metric,'Euclidean')
  
  % Use caution: WILL PRODUCE IMAGINARY NUMBERS IF any x \in X == any c \in C
  %fprintf('d=0: %d, d<0: %d\n',sum(zerov(:)), sum(negv(:)));
  %pause
  
  %d(zerov) = 1;
  %Xr = sqrt(d);
  %Xr(zerov) = 0;
  
  Xr = sqrt(d);  
  Xr = sumnorm(Xr); % sum-row normalize
end

