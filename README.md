# RelTrans: RELational class knowledge TRANSfer (RelTrans) framework

## Algorithm Summary 

This code provides an implementation of the RELational class knowledge TRANSfer (RelTrans) algorithm for multiclass domain adaptation.  

## System Requirements 

Tested using Matlab 7.14.0.739 (R2012a) on a Macbook Pro running OSX 10.6.

## Disclaimer 

Although this code has been reasonably well-tested, it is research code, and may contain bugs. Please refer to the FAQ below for info on commonly-occurring issues, and feel free to contact the author (bbue@alumni.rice.edu) if you have any difficulties using the code. 

## Installation 

Run the following code to add the RelTrans functions to your path:

```matlab
RT_ROOT='/path/to/RelTrans/';
addpath(genpath(RT_ROOT));
savepath; % optional
```
## Example Usage and Output 

See demo/reltrans_demo.m for an example of how to use RelTrans in your code.

## FAQ 

Q: Should I preprocess my data in some way before running RelTrans? 
A: Yes, make sure your source and target features/samples are mapped to a similar numerical range before running RelTrans. We typically scale each sample x \in {S, T, SU, TU} by its L^2 norm (i.e., x = x/\|x\|_2) to deal with scaling factors caused by varying illumination conditions that commonly occur with hyperspectral image spectra, but other scaling techniques may also work well. 

Q: How similar must the source and target domain spectra be in order for RelTrans to work properly?
A: The degree of improvement depends on (a) the complexity of the classification task, and (b) if the source domain samples are a reasonable representation of the target domain classes. A good rule-of-thumb is: if the source and target domain samples appear (visually) substantially different after scaling their features to the same numerical range, RelTrans (or, for that matter, any unsupervised domain adaptation algorithm) will likely not improve prediction accuracy. Alternatively, if you expect a source-trained classifier to produce predictions better than random guessing on the target domain samples, then RelTrans will typically improve your prediction accuracy. One obvious exception is when source-to-target accuracy is already very high (e.g., 95+%), and thus, domain adaptation is unnecessary.

Q: Is there a limit on the number of classes we can consider?
A: In theory, no, but (as with any classification problem) if the classes are very similar, subtle differences between them may be difficult to distinguish. Additionally, samples from identical classes should be relatively similar to one another across domains -- for instance, source samples representing a "tree" class should appear similar (at least visually) to target samples that represent the "tree" class. See the paper and additional references below for examples. 

## Citation 

Please cite the following paper if you use the RelTrans code in your publication:

>  B. D. Bue and D. R. Thompson, “Multiclass Continuous Correspondence Learning,” NIPS Domain Adaptation Workshop, Dec. 2011.

## Additional References 

>  B. D. Bue and E. Merényi, “Using spatial correspondences for hyperspectral knowledge transfer: evaluation on synthetic data,” Workshop on Hyperspectral Image and Signal Processing: Evolution in Remote Sensing (WHISPERS), Jun. 2010.
>  B. D. Bue, E. Merényi, and B. Csathó, “An Evaluation of Class Knowledge Transfer from Real to Synthetic Imagery,” Workshop on Hyperspectral Image and Signal Processing: Evolution in Remote Sensing (WHISPERS), Jun. 2011.


## Changelog 

06/19/13 - initial release.

## Contact 

Please contact the author (bbue@alumni.rice.edu) if you have any questions
regarding this code.

