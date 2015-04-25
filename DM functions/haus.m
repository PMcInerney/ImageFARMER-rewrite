function HDD = haus(XI,XJ)
  %XI is a row vector representing an image
  %XJ is a set of row vectors representing other images
  num_js = size(XJ,1);
  XJ2 = XJ';
  distM = reshape(pdist2(XI',XJ2(:)),[size(XI,2),size(XJ,2),size(XJ,1)]);
  HD1 = max(min(distM,[],1),[],2);
  HD1 = reshape(HD1,[1,num_js]);
  HD2 = max(min(distM,[],2),[],1);
  HD2 = reshape(HD2,[1,num_js]);
  HDD = max(HD1,HD2);

