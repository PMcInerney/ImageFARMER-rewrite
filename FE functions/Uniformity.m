function uniformity = Uniformity(I)
  p=imhist(I);
  p=p./numel(I) ;
  uniformity=sum(p.^ 2);           
