function paramEvalGen(x)
%this function builds weka data for parameter evaluation, apparently.
%%%%%%%%%%%%%%%%%%%
%%%build image list
%%%%%%%%%%%%%%%%%%%

x = x

x.numClasses = 8;
if ~x.useFile
  %build list of classes assuming directory structure

  classes = dir(x.datasetDir);
  classes = classes([classes.isdir]) ;
  classes = {classes(3:x.numClasses+2).name};
  imageFileNames = {} ;
  imageClasses = {} ;
  for ci = 1:length(classes)% for each class/folder
    classIms = dir(fullfile(x.datasetDir, classes{ci}, ['*.' x.exten])) ;
    classIms = cellfun(@(y)fullfile(x.datasetDir,classes{ci},y),{classIms.name},'UniformOutput',false);
    imageFileNames = {imageFileNames{:}, classIms{:}} ;
    imageClasses{end+1} = repmat(classes(ci), 1,length(classIms)) ;
  end
  imageClasses = cat(2, imageClasses{:});
  for ii = 1:length(classes)
    classes{ii} = strrep(classes{ii}, ' ', '_');
  end
else
 %build List of classes assuming file list
  disp('importing image list from file');
  f = fopen(x.imageListFile);
  M = textscan(f,'%s','Delimiter','\n');
  fclose(f);
  M = M{1};
  imageFileNames = M(1:3:end);
  eventCells = M(2:3:end);
  imageClasses = M(3:3:end);
  classes = unique(imageClasses);
  for ii = 1:length(classes)
    classes{ii} = strrep(classes{ii}, ' ', '_');
  end
end



if(exist(x.FVPath))
  disp('loading feature data');
  load(x.FVPath);
  disp('data loaded');
else
  disp('no data found');
  return;
end

FV(:,:,7) = 10000*FV(:,:,7); % Multiply TamCon by 10k to try to overcome weka issues
FV(:,:,9) = 1000*FV(:,:,9); % Multiply RS by 1k to try to overcome weka issues

disp('reformatting FV');
%1600x1024x10 FV which we want to restructure
S = size(FV);
FV_P = permute(FV,[2 1 3]);
FV_R = reshape(FV_P,[S(1)*S(2),S(3)]);

disp(size(imageClasses));
xderp = imageClasses;
yderp = repmat(xderp,[S(2),1]);
zderp = reshape(yderp,[S(1)*S(2),1]);

%if ~exist(x.FE_arffFilename)
if true
  disp('building weka data matrix')
  featureNames = {'mean','stdDev','skewness','kurtosis','entropy','FracDim','TamCon','TamDir','RS','Uniformity'};
  
  % we need the labels

  try
    disp('making weka object');
    tic
      fid = fopen(x.FE_arffFilename,'w');
      fprintf(fid,'@relation derp\n\n');
      for ii = 1:length(featureNames)
        fprintf(fid,'@attribute %s numeric\n',featureNames{ii});
      end
      s = [sprintf('%s,',classes{1:end-1}), classes{end}];
      fprintf(fid,'@attribute label {%s}\n\n',s);

      fprintf(fid,'@data\n');
      for ii = 1:length(FV_R)
        if mod(ii,1000) == 0
          fprintf('%d/%d\n',ii,length(FV_R));
        end
        dataLine = FV_R(ii,:);
        dataLineStrings = arrayfun(@(y)sprintf('%.10f ', y),dataLine,'UniformOutput',false);
        writableDataLine = cat(2,dataLineStrings{:});
        fprintf(fid,'%s%s\n',writableDataLine,zderp{ii});
      end
      fclose(fid);
    toc
  catch err
    disp('arff creation failed');
    disp(err);
    disp(err.message);
  end
else
  disp('arff already created')
end
