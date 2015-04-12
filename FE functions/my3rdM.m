function moment3 = my3rdM(I)
  p=imhist(I);
  p=p./numel(I) ;
  moment3=skewness(p);
