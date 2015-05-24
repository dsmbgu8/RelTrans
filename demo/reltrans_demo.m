% noisy XOR example
% - two classes, two domains
% - testing data rotated by test_rot_angle degrees w.r.t. training data
% - nonlinearly separable with domain shift in the original feature space
% - linearly separable in the R-space with a sufficient quantity of
%   unlabeled examples used in the R-transform

clear all; close all;
addpath(genpath('../src'));

% parameters
rel_metric='Euclidean'; % 'EuclideanSquared'; % 'RBF'; % 'RBFSumNorm'; % 
plot_data=1;
plot_rel=1;
test_rot_angle = 20; % angle of rotation of test data from training samples
ntrials=5; % number of random trials to average in measuring accuracy

% add a Gaussian in each quadrant
nsper=100; % samples per Gaussian
nGauss = 4;
scalef = 1.0;
var = 0.05;
mus = ([1,1; -1,1; -1,-1; 1,-1]*scalef);
covs = {};
for i=1:nGauss, covs = [covs; eye(2)*var]; end;

nsamp = nGauss*nsper; % total samples per domain
[vecs, labs] = gen2DGaussians(nsper, mus', covs);

% assign to two classes
class1 = [1,3]; class2 = [2,4];
labs((labs==class1(1)) | (labs==class1(2))) = 1;
labs((labs==class2(1)) | (labs==class2(2))) = 2;

% color vectors
c = labs/max(labs(:));
cmu = [1 2 1 2]'/2;
samp_idx = 1:length(labs);

% plot params
plotf = 1.8; dotsize=20; musize=100;

if plot_data
  figure(1)
  suptitle('Original (training) features')
  hold on;
  scatter(vecs(:,1),vecs(:,2),dotsize,c)
  scatter(mus(:,1),mus(:,2),musize,'k','s')
  xlim([-plotf*scalef,plotf*scalef])
  ylim([-plotf*scalef,plotf*scalef])
  hold off;
end

% generate some test (target) data
% rotate the target data w.r.t. the source data to simulate domain shift
anglerad = test_rot_angle*(pi/180.0);
rot = [cos(anglerad), -sin(anglerad);
       sin(anglerad),cos(anglerad)];

temus = mus*rot;
[tevecs, telabs] = gen2DGaussians(nsper, temus', covs);


telabs((telabs==class1(1)) | (telabs==class1(2))) = 1;
telabs((telabs==class2(1)) | (telabs==class2(2))) = 2;

if plot_data
  figure(2)
  suptitle('Original (testing) features')
  hold on;
  scatter(tevecs(:,1),tevecs(:,2),dotsize,c)
  scatter(temus(:,1),temus(:,2),musize,'k','s')
  xlim([-plotf*scalef,plotf*scalef])
  ylim([-plotf*scalef,plotf*scalef])
  hold off;
end


%  plot each mu in the R-space with the chosen rel_metric
if plot_rel
  figure(3);
  suptitle('\mu vectors (training data) in R-space')
  for i=1:nGauss
    subplot(nGauss,1,i)
    mu = mus(i,:);
    %rel = exp(-fast_dmtx(mu',vecs')/2.0);
    rel = relK(mu,vecs,rel_metric);
    if (mu(1)*mu(2)>0), pc='b'; else, pc='r'; end;
    scatter(samp_idx,rel,dotsize,pc,'o');
    for j=0:nGauss-1
      line([j*nsper,j*nsper],[min(rel(:)),max(rel(:))],'Color','k');
    end
    ylabel(['\mu=[',num2str(mu),']']);
  end
  
  figure(4);
  suptitle('\mu vectors (test data) in R-space')
  for i=1:nGauss
    subplot(nGauss,1,i)
    mu = temus(i,:);
    %rel = exp(-fast_dmtx(mu',vecs')/2.0);
    rel = relK(mu,tevecs,rel_metric);
    if (mu(1)*mu(2)>0), pc='b'; else, pc='r'; end;
    scatter(samp_idx,rel,dotsize,pc,'o');
    for j=0:nGauss-1
      line([j*nsper,j*nsper],[min(rel(:)),max(rel(:))],'Color','k');
    end
    ylabel(['\mu=[',num2str(mu),']']);
  end  
end

% show mindist classification accuracy in kernel-projected space
npercents = 100; % # of percentages to sample from unlabled data
percents = linspace(1.0/npercents,1.0,npercents+1);



% base prediction = will be ~50% since nonlin sep + equal class
% conditionals
basepred = mindist(tevecs,vecs,labs); 
cmat = confusionmat(telabs,basepred);
baseacc = trace(cmat)/double(sum(cmat(:)));

trialacc = [];
for t = 1:ntrials
  sampacc = [];
  
  % permute samples in each trial
  trperm = randperm(nsamp);
  trvec = vecs(trperm,:);
  trlab = labs(trperm);
  teperm = randperm(nsamp);
  tevec = tevecs(teperm,:);
  telab = telabs(teperm);    
  
  % sample sampper percent of "unlabeled" samples
  for sampper = percents    
    nsamp_per = floor(max(2,nsamp*sampper));
    per_idx = samp_idx(randperm(nsamp_per));
    samp_vecs = trvec(per_idx,:);
    
    % map to R space
    trrel = relK(trvec,samp_vecs,rel_metric);
    terel = relK(tevec,samp_vecs,rel_metric);

    % get prediction for this mapping
    tepred = mindist(terel,trrel,trlab);
    cmat = confusionmat(telab,tepred);
    acc = trace(cmat)/double(sum(cmat(:)));
    
    sampacc = [sampacc acc];  
  end
  trialacc = [trialacc; sampacc];
end

figure(5)
hold on;
plot(percents,mean(trialacc));
ylabel('accuracy');
xlabel('% unlabeled samples used in R transform');
suptitle(sprintf('RelTrans accuracy (baseline accuracy=%0.3f)', baseacc));
hold off;