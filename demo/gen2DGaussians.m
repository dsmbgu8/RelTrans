function [vecs,labs] = gen2DGaussians(nper,mus,covs)

vecs = []; labs = [];
for i=1:size(mus,2)
  mu = repmat(mus(:,i)',nper,1);
  muvecs = mu + randn(nper,2)*chol(covs{i});
  vecs = [vecs; muvecs];
  labs = [labs; zeros(nper,1)+i];
end