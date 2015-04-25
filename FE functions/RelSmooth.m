function rs = RelSmooth(I)
  p=imhist(I);
  p=p./numel(I) ;
  rs=1-(1/ (1+(std(p)^2))); 
