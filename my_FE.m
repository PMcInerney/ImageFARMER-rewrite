function my_FE(varargin)

if nargin == 1
  alt_config = varargin{1};
else
  alt_config = [];
end

%%%%% Main Variables

config_ops = my_CBIR_config(alt_config);
%%% Global information
numClasses = config_ops.numClasses;
numSegments = config_ops.numSegments;
sizeSegments = config_ops.sizeSegments;
numCells = config_ops.numCells;
dataSet = config_ops.dataSet;
exten = config_ops.exten;
datasetDir = config_ops.datasetDir;
outputDir = config_ops.outputDir;
if ~exist(outputDir,'dir')
    mkdir(outputDir);
end
imageParameters = config_ops.imgParameters;
imageFunctions = config_ops.imgFunctions;
imageFunctionParameters = config_ops.imgFuncParams;
singleParamClassification = config_ops.singleParamClassification;
FVPath = config_ops.FVPath;
imageClassLabelsPath = config_ops.imageClassLabelsPath;
imagesfile = config_ops.imageListFile;
useFile = config_ops.useFile;
writeParameterImages = config_ops.FE_writeParameterImages;
%%% Local Information
param_vis = config_ops.FE_param_vis;      %1 for displaying graphs
feat_ext = config_ops.FE_feat_ext;    %1 for extracting features
weka_write = config_ops.FE_weka_write;%1 for writing weka files for classification
arffFilename=config_ops.FE_arffFilename;
readFunction=config_ops.FE_readFunction;
readFunctionParameters = config_ops.FE_readFunctionParameters;
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% End of configuration
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% data setup
if ~useFile
  %% build list of classes assuming directory structure

  classes = dir(datasetDir);
  classes = classes([classes.isdir]) ;
  classes = {classes(3:numClasses+2).name};
  imageFileNames = {} ;
  imageClassLabels = {} ;

  for ci = 1:length(classes)% for each class/folder
    classIms = dir(fullfile(datasetDir, classes{ci}, ['*.' exten]));
    classIms = cellfun(@(x)fullfile(datasetDir,classes{ci},x),{classIms.name},'UniformOutput',false);
    imageFileNames = [imageFileNames, classIms];
    imageClassLabels{end+1} = repmat(classes(ci), 1,length(classIms)) ;
  end
  imageClassLabels = cat(2, imageClassLabels{:});
else
 %% build List of classes assuming file list
  disp('importing image list from file');
  f = fopen(imagesfile);
  M = textscan(f,'%s','Delimiter','\n');
  fclose(f);
  M = M{1};
  imageFileNames = M(1:3:end);
  eventCells = M(2:3:end);
  imageClassLabels = M(3:3:end);
  classes = unique(imageClassLabels);
end
% save imageClassLabels so we can access it from other modules
save(imageClassLabelsPath,'imageClassLabels');


testimage = rand(100,100);
% if the output of an image function is more than one value, we need to
% accomodate that in our data structure
expandedImageParameters = {};
for param_num = 1:length(imageParameters)
  value =  imageFunctions{param_num}(testimage,imageFunctionParameters{param_num}{:});
  l = length(value);
  if l > 1
    nums = cellfun(@num2str,num2cell(1:l),'UniformOutput',false);
    repImageParameter = repmat(imageParameters(param_num),[1 l]);
    expandedSingleImageParameter = cellfun(@strcat,repImageParameter,nums,'UniformOutput', false);
  else
    expandedSingleImageParameter = imageParameters(param_num);
    
  end
  expandedImageParameters = cat(2,expandedImageParameters,expandedSingleImageParameter);
end


disp('data set up')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Extract the parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if feat_ext==1
  % try to load from computed files
  if(exist(FVPath,'file'))
    disp('loading feature data');
    load(FVPath);
    disp('data loaded');
  else
    disp('calculating parameter values')
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %% setup the FV structure
    %%%%%%%%%%%%%%%%%%%%%%%%%%



    FV = zeros(length(imageFileNames),numCells,length(expandedImageParameters));
    for ii = 1:length(imageFileNames)
        completeFileLocation = fullfile(imageFileNames{ii});
        I = readFunction(completeFileLocation,readFunctionParameters{:});
        
        % Create variable size grids
        imageInfo = imfinfo(completeFileLocation); % read image info
        im_y=imageInfo.Height;
        im_x=imageInfo.Width;
        chunkX = round(im_x*sizeSegments); %x size of a grid cell
        chunkY = round(im_y*sizeSegments); %y size of a grid cell
        moveX = (im_x-chunkX)/(numSegments-1);
        moveY = (im_y-chunkY)/(numSegments-1);
        
        % go through each cell of the image, and calculate the parameters
        x=1;
        y=1;
        x2=chunkX;
        y2=chunkY;
        cellCounter = 0;
        for iRow=1:numSegments %rows 
          for iCol=1:numSegments  %columns
            cellCounter = cellCounter +1;
            cellRange=I(y:y2,x:x2);
            parameterCounter = 1;
            for param_num = 1:length(imageParameters)
              if numel(cellRange) >0
                value =  imageFunctions{param_num}(cellRange,imageFunctionParameters{param_num}{:});
                FV(ii,cellCounter,parameterCounter:parameterCounter+length(value)-1) = value;
                parameterCounter = parameterCounter+length(value);
              else
                FV(ii,cellCounter,param_num) = 0;
                disp('problem encountered')
              end                
            end
            
            x=x+moveX;
            x2=x2+moveX;
            if x2>im_x
              x2=im_x;
            end
          
          end % columns
          y=y+moveY;
          y2=y2+moveY;
          %Check for out of bounds in rows
          if y2>im_y
            y2=im_y;
          end
          %Initialize column
          x=1;
          x2=chunkX;
        end % rows
    end % loop over images
    disp(sum(FV(:)==0));

    save(FVPath,'FV');
    disp('Image Feature Extraction Done...');
  end
end %Feature Extraction

%%%%%%%%%%%%%%%%%%%%%%%%%
%% write parameter images
%%%%%%%%%%%%%%%%%%%%%%%%%
if writeParameterImages
  disp('writing parameter images');
  for paramNum = 1:length(imageParameters) % for each parameter
    param = imageParameters{paramNum};
    Y = squeeze(FV(:,:,paramNum));

    X = max(Y(:));
 
    count = 1;
    x = '000';
    for ii = 1: size(FV,1) % for each image
      I = squeeze(Y(ii,:));
      class_I = imageClassLabels{ii};
      I = reshape(I,[numSegments numSegments])';
      I = I/X;

      folder = fullfile(outputDir,param,['class ',class_I]);
      if ~exist(folder,'dir')
        mkdir(folder);
      end

      name = fullfile(folder,[x num2str(count) '.png']);
      if ~exist(name,'file')
          imwrite(I,name,'png');
      else 
          fprintf('%s already exists\n',name);
      end
      count = count +1;
      x = repmat('0',[1 4-length(num2str(count))]);
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%
%% Weka writing
%%%%%%%%%%%%%%%%%%%%%%%%
if weka_write
  if ~exist(FVPath,'file')
      disp('No image parameters have been extracted');
      exit;
  end
  %%Save WEKA file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Use the FV data structure
%%%% to build weka data structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  if ~exist(arffFilename,'file')
  %disp('skipping full parameter')
  %if false
    disp('building weka data matrix')
    featureNames = {};
    rows = {};
    for ii = 1:length(imageFileNames)
      %each row of the data is an image
      rowparts = {};
      for param_num = 1:length(expandedImageParameters)
        values = cat(2,FV(ii,:,param_num));
        %values is a 1xcells float array of parameter values for a specific image
        if ii == 1
          %%%% create the list of feature names
          numCellsTimesNumVals = length(values);
          numVals = numCellsTimesNumVals/numCells;
           
          name = expandedImageParameters(param_num);
          nameRep = repmat(name,[1,numCells*numVals]);
          
          cRep = repmat({'c'},[1,numCells*numVals]);
        
          cells = 1:numCells;
          cells = arrayfun(@num2str,cells,'UniformOutput',false);
          cellsRep = repmat(cells,[1,numVals]);
        
          vals = 1:numVals;
          vals = arrayfun(@num2str,vals,'UniformOutput',false);
          valsRep = repmat(vals,[1,numCells]);
        
          X = cellfun(@strcat,nameRep,valsRep,cRep,cellsRep,'UniformOutput',false);
          featureNames = cat(2,featureNames,X);
          %%%%
        end
        rowparts{param_num} = values;
      end
      rows{ii} = cat(2,rowparts{:});
    end % end of images loop;
    tempData = cat(1,rows{:});

    disp('writing parameter arff file');
    myWriteWeka(arffFilename,'derp',featureNames,classes,tempData,imageClassLabels)

    
  else
    disp('weka already created')
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%% make ARFF for each parameter
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if singleParamClassification
    for param_num = 1:length(expandedImageParameters)
      [basefolder,~,~] = fileparts(arffFilename);
      paramArffFilename = fullfile(basefolder,makeARFFFilename(dataSet,[num2str(numSegments) 'x' num2str(numSegments)],expandedImageParameters{param_num},''));
      if ~exist(paramArffFilename,'file')
        disp('building weka data matrix')
        featureNames = {};
        rows = {};
        for ii = 1:length(imageFileNames)
          %each row of the data is an image
          values = cat(2,FV(ii,:,param_num));
          %values is a 1xcells float array of parameter values for a specific image
          if ii == 1 % if this is the first image
            %%%% create the list of feature names
            numCellsTimesNumVals = length(values);
            numVals = numCellsTimesNumVals/numCells;
            
            name = expandedImageParameters(param_num);
            nameRep = repmat(name,[1,numCells*numVals]);
            
            cRep = repmat({'c'},[1,numCells*numVals]);
            
            cells = 1:numCells;
            cells = arrayfun(@num2str,cells,'UniformOutput',false);
            cellsRep = repmat(cells,[1,numVals]);
            
            vals = 1:numVals;
            vals = arrayfun(@num2str,vals,'UniformOutput',false);
            valsRep = repmat(vals,[1,numCells]);
            
            X = cellfun(@strcat,nameRep,valsRep,cRep,cellsRep,'UniformOutput',false);
            featureNames = cat(2,featureNames,X);
            %%%%
          end
          rows{ii} = values;
        end % end of images loop;
        tempData = cat(1,rows{:});
        disp('writing single parameter arff file');
%        wekaObject = matlab2weka('derp',featureNames,tempData);
%        saveARFF(paramArffFilename,wekaObject);
        myWriteWeka(paramArffFilename,'derp',featureNames,classes,tempData,imageClassLabels)
      
      else
        disp('individual parameter weka already created')
      end
    end % end individual parameter loop 
  end % end single parameter ARFF creation
end % write weka block

disp('Feature Extraction Demo has been completed. Check your output folder for results')
