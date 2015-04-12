function boxCount = myFracDim(I)
try
  boxCount = new_bc(I,3,0);
catch e
  disp('error in boxCount')
  boxCount = 0;
  rethrow(e)
end
  if isnan(boxCount) 
     boxCount = 1.646;
  else
    if  boxCount < 0
      boxCount = 0;
    elseif ~ isfinite(boxCount)
      boxCount = 1.646;
    end
  end
