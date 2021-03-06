function KLD = KLDAB(XI,XJ)
% my_KLD(XI,XJ)
% XI is a row vector representing an image
% XJ is a set of row vectors representing other images
% 
  num_Js = size(XJ,1);
  XI = repmat(XI,num_Js,1);
  temp = XI.*log2(XI./XJ);
  temp(isnan(temp))=0;
  temp(isinf(temp))=0;
  KLD = sum(temp,2)';
  KLD = real(KLD);