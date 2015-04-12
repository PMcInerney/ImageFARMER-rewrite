function [FV, imageClassLabels] = loadData(FVPath,imageClassLabelsPath)
if(exist(FVPath,'file'))
  load(FVPath);
disp('feature data loaded');
else
  error('no Extracted Features found');
end
if(exist(imageClassLabelsPath,'file'))
  load(imageClassLabelsPath);
  disp('image class labels loaded');
else
  error('no class labels found');
end
