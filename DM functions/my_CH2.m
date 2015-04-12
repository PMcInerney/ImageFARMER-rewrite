function CH2 = my_CH2(XI,XJ)
%XI is a row vector representing an image
%XJ is a set of row vectors representing other images
  num_Js = size(XJ,1);
  XI = repmat(XI,num_Js,1);
  temp=(XI-XJ) ./ (XI+XJ) ;
  temp(isnan(temp))=0;
  CH2 = abs(sum(temp,2)');
