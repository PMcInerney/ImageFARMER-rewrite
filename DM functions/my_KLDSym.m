function KLD = my_KLDSym(XI,XJ)
% my_KLD(XI,XJ)
% XI is a row vector representing an image
% XJ is a set of row vectors representing other images
% 
  num_Js = size(XJ,1);
  XI = repmat(XI,num_Js,1);
  temp = XJ.*log2(XJ./XI)+XI.*log2(XI./XJ);
  temp(isnan(temp))=0;
  temp(isinf(temp))=0;
  KLD = sum(temp,2)';
  KLD = real(KLD); % this is a total hack