function [SPI,TCI] = filter_pivots(SP,SPL,TC,TCL,nkeep)
% Selects the nkeep best-aligned pivots from the two sets SP and TC
% Input:
%  (SP,SPL) = labeled source pivots
%  (TC,TCL) = labeled target pivots
%  nkeep = if scalar -> selects same number of pivots for each class 
%          if vector -> selects nkeep(j) pivots for class j
% Output:
%  (SPI, TCI) = the indices into the original SPL,TCL vectors
%               (separate to handle trimming)

USL = unique(SPL); 
K = numel(USL); 

if numel(nkeep) == 1 
  nkeep = ones([K,1])*nkeep;
end

ntrim=min([nkeep'; class_counts(SPL)'; class_counts(TCL)'],[],1);
% if numel(SPL) ~= numel(TCL)
%   disp('merge_corr: SP, TC not aligned, trimming.')
%   disp('SP:')
%   sccount=class_counts(SPL,1);
%   disp('TC:')
%   tccount=class_counts(TCL,1);
%   ntrim = min([nkeep'; sccount'; tccount'],[],1)
% end

SPtrim = []; TCtrim = [];

SPM = class_means(SP,SPL);
TCM = class_means(TC,TCL);

for j=1:K
  Sidxj = find(SPL==USL(j));
  Tidxj = find(TCL==USL(j));

  if 0
    SPj = SP(Sidxj,:);
    TCj = TC(Tidxj,:);
    rSMj = relK(SPj,SPM);
    rTMj = relK(TCj,TCM);
    
    dmtxj = fast_dmtx(rSMj',rTMj');
    [minv,mindx] = min(dmtxj,[],2);
    [minvsort,mindxsort] = sort(minv);

    Sidxj = Sidxj(mindxsort);
    Tidxj = Tidxj(mindx(mindxsort));
  end

  SPtrim = [SPtrim; Sidxj(1:ntrim(j))];
  TCtrim = [TCtrim; Tidxj(1:ntrim(j))];
end

SP = SP(SPtrim,:);
TC = TC(TCtrim,:);
SPL = SPL(SPtrim);
TCL = TCL(TCtrim);


SPI = []; TCI = [];
for j=1:K
  Sidxj = find(SPL==USL(j));
  Tidxj = find(TCL==USL(j));
  
  nkeepj = min(nkeep(j),numel(Sidxj));
  
  if sum(Sidxj==Tidxj) ~= numel(Sidxj)
    fprintf('merge_corr: SP%d, TC%d not aligned\n. SP%d: %d, TC%d: %d,',...
            j,j,j,numel(Sidxj),j,numel(Tidxj))
    pause
  end
   
  SPj = SP(Sidxj,:);
  TCj = TC(Tidxj,:);
  rSPj = relK(SPj,SP);
  rTCj = relK(TCj,TC);
  
  dists = diag(fast_dmtx(rSPj',rTCj'));
  [sorted,keep] = sort(dists);

  keepj = Sidxj(keep(1:nkeepj));
  SPI = [SPI; SPtrim(keepj)]; 
  TCI = [TCI; TCtrim(keepj)];
end


