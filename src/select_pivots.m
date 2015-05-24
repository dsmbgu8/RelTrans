function pivots = select_pivots(S,SL,T,TL,Qk,SU,TU);
%% Selects pivot samples representing similar classes in source and target domains
% Input: 
%  S = NS x n matrix of source samples
%  SL = NS x 1 vector of source labels
%  T = NT x n matrix of target samples
%  TL = NT x 1 vector of target labels (optional, use [] if unavailable)
%  Qk = number of pivots to select per class
%  SU = NSu x n matrix of unlabeled source samples (optional, use [] if unavailable)
%  TU = NTu x n matrix of unlabeled target samples (optional, use [] if unavailable)
% Output:
%  pivots = struct with the following fields
%    pivots.srcTrueIdx = indices in S of labeled source pivots
%    pivots.srcTrueLab = labels of source pivots
%    pivots.srcTrueTgtIdx = indices in S of labeled source pivots aligned to true targets
%    pivots.srcTrueTgtLab = labels of source pivots aligned to true targets
%    pivots.tgtTrueIdx = indices in T of labeled target pivots (empty if TL=[])
%    pivots.tgtTrueLab = labels of target pivots (empty if TL=[])
%    pivots.tgt2srcIdx = indices in T of target pivots matched to srcTrueIdx
%    pivots.tgt2srcLab = predicted labels of target pivots
%    pivots.srcUnlabIdx = indices in SU of unlabeled source pivots
%    pivots.srcUnlabLab = predicted labels of srcUnlabIdx
%    pivots.tgtUnlabIdx = indices in TU of unlabeled target pivots matched to labeled target pivots (empty if TL=[])
%    pivots.tgtUnlabLab = predicted labels of tgtUnlabIdx (empty if TL=[])
%    pivots.tgt2srcUnlabIdx = indices in TU of unlabeled target pivots matched to srcTrueIdx
%    pivots.tgt2srcUnlabLab = predicted labels of tgt2srcUnlabIdx



USL = unique(SL);
K = length(USL);

% 1. pivots from labeled source (S) to labeled source samples (S) 
%    source samples nearest to source class means
SM = class_means(S,SL);
[SCI, SCL] = unique_neighbors(fast_dmtx(S',SM')',USL,Qk);
SC = S(SCI,:);
SCL = SL(SCI);

% 2. if unlabeled source data provided, use it
%    pivots from labeled source (S) to unlabeled source samples (SU)
SCUI = []; SCUL = [];
STUI = []; STUL = [];
if (exist('SU','var') & ~isempty(SU)) 
  % unlabeled source samples nearest source means
  [SCUI, SCUL] = unique_neighbors(fast_dmtx(SU',SM')',USL,Qk);
  SCU = SU(SCUI,:);
end


% === 3. supervised: use labeled target data (TL) to select pivots ===
SSI = SCI; SSL = SCL;
TTI = []; TTL = [];
TCUI=[]; TCUL=[];
if ~isempty(TL) 
  % 3a: target samples nearest to target class means
  %     pivots from labeled target (T) to labeled target samples (T)
    
  TM = class_means(T,TL);
  UTL = unique(TL);
  if length(UTL) ~= length(USL)
    disp('warning: different source and target classes');
    pause;
  end
  [TTI, TTL] = unique_neighbors(fast_dmtx(T',TM')',UTL,Qk);
  TTC = T(TTI,:);

  % 3b: aligned source pivots to target means
  %     pivots from labeled source (S) to labeled target samples (T)
  [SSI, SSL] = unique_neighbors(fast_dmtx(relK(SC,SC)',relK(TTC,TTC)')',TTL,1);
  SSI = SCI(SSI); % note: do not update SSL, since we just want to reorder here
  countS = class_counts(SSL);
  countT = class_counts(TTL);
  use_all_src=0;
  if (numel(countS)~=numel(countT))
    use_all_src=1;
  elseif sum(countS==countT) ~= numel(countS)
    use_all_src=1;
  end
  if use_all_src
    [SSI, SSL] = unique_neighbors(fast_dmtx(relK(S,SC)',relK(TTC,TTC)')',TTL,1);
  end
  
  % 3c: unlabeled target samples nearest target class means
  %     pivots from labeled target (T) to unlabeled target samples (TU)
  if (exist('TU','var') & ~isempty(TU))    
    [TCUI, TCUL] = unique_neighbors(fast_dmtx(TU',TM')',UTL,Qk);
    TCU = TU(TCUI,:);
  end  
end

% === 4. unsupervised: assume target data (T) unlabeled === 
% 4a: use MCCL to select pivots from labeled source (S) to unlabeled 
%     target samples (T) in R-space
[STI, STL] = unique_neighbors(fast_dmtx(relK(T,SC)',relK(SC,SC)')',SCL,1); 

% 4b: use MCCL to select pivots from unlabeled source samples (SU) nearest 
%     unlabeled target samples (TU) in R-space
if ~isempty(SCUI) & (exist('TU','var') & ~isempty(TU))  
  [STUI, STUL] = unique_neighbors(fast_dmtx(relK(TU,SCU)',relK(SCU,SCU)')',SCUL,1); 
end


pivots = struct();

% === source pivots (near class means) ===
pivots.srcTrueIdx = SCI;
pivots.srcTrueLab = SCL;
pivots.srcTrueTgtIdx = SSI;
pivots.srcTrueTgtLab = SSL;
pivots.srcUnlabIdx = SCUI;
pivots.srcUnlabLab = SCUL;

% === supervised target and target-to-source pivots === 
pivots.tgtTrueIdx = TTI;
pivots.tgtTrueLab = TTL;
pivots.tgtUnlabIdx = TCUI;
pivots.tgtUnlabLab = TCUL;

% === unsupervised labeled and unlabeled target-to-source pivots === 
pivots.tgt2srcIdx = STI;
pivots.tgt2srcLab = STL;
pivots.tgt2srcUnlabIdx = STUI;
pivots.tgt2srcUnlabLab = STUL;


