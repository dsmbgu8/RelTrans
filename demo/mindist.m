function [pred,model] = mindist(Xte,Xtr,ytr,model,dmtx)

ulab=unique(ytr);
k=length(ulab);

if ~exist('model')
  model = class_means(Xtr,ytr);
end

if ~exist('dmtx')
  dmtx=fast_dmtx(Xte',model');
end

[c,i] = min(dmtx,[],2);
pred = ulab(i);


