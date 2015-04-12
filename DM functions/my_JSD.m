function JSD = my_JSD(XI,XJ)
%XI is a row vector representing an image
%XJ is a set of row vectors representing other images
  num_Js = size(XJ,1);
  XI = repmat(XI,num_Js,1);
  temp=XI.*log2( (2*XI) ./ (XI+XJ) ) + XJ.* log2( (2*XJ) ./ (XI+XJ) );
  temp(isnan(temp))=0;
  JSD = sum(temp,2)';
  JSD = real(JSD); % this is a total hack