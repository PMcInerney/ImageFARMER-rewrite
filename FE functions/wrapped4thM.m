function moment4 = wrapped4thM(I)
  p=imhist(I);
  p=p./numel(I) ;
  moment4=kurtosis(p);
