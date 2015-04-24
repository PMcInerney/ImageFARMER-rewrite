function [FD, imageClassLabels] = loadData(FDPath,imageClassLabelsPath)
if(exist(FDPath,'file'))
  s = load(FDPath,'FD');
  FD = s.FD;
else
  error('no Extracted Features found');
end
if(exist(imageClassLabelsPath,'file'))
  s = load(imageClassLabelsPath,'imageClassLabels');
  imageClassLabels = s.imageClassLabels;
else
  error('no class labels found');
end
