function moment4 = my4thM(I)
  p=imhist(I);
  p=p./numel(I) ;
  moment4=kurtosis(p);
