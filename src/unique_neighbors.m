function [kI,kL,kD] = unique_neighbors(dmtxTeTr,trLab,K)
% Returns the set of K *unique* training samples nearest to each test sample,
% such that the set of samples matched to test point i \ne the set of samples 
% matched to test point j, j \ne i
%
% Input:
%  dmtxTeTr = Nte x Ntr matrix of distances from test samples to training samples
%  trLab = Ntr x 1 vector of training labels
%  K = number of unique neighbors per test sample to match to training samples
% Output:
%  kI = indices of matched samples
%  kL = training labels of matched samples
%  kD = distances from test samples to matched samples

[Nte Ntr] = size(dmtxTeTr);
kI = []; kL = []; kD = [];
available = true([1,Ntr]); 
for i=1:Nte  
  aidx = find(available);
  if length(aidx)==0, continue, end; % all samples already matched
  
  % get distances between test sample i and unmatched training samples
  disti = dmtxTeTr(i,available); 
  minvals = sort(disti);
  mindex = min(length(minvals),K); % K nearest unmatched neighbors
  thresh = minvals(mindex);
  distidx = find(disti <= thresh);
  didx = aidx(distidx);
  
  kI = [kI, didx(1:mindex)];  
  kL = [kL; ones([mindex,1])*trLab(i)];
  kD = [kD, disti(distidx)];
  available(didx)=false; % flag matched training samples as unavailable
end

