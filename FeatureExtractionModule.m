%    ImageFARMER-Rewrite  Feature Extraction Module
%    Copyright (C) 2015  Patrick McInerney
%    Copyright (C) 2012  Juan M. Banda, Rafal A. Angryk
%    Contact: pmmciner@gmail.com
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%
%
%  FeatureExtractionModule()
%   Runs the Feature Extraction Module of the
%   IMAGEFarmer-Rewrite CBIR building framework.
%
%   The other modules (Attribute Evaluation, Dissimilarity Measures, and
%   Dimensionality Reduction) are dependent on the 'FD.mat' and 'CL.mat'
%   outputs of this module for operation.
%   
%   FeatureExtractionModule(alt_config) takes any valid configuration 
%   fields provided in the struct alt_config and substitutes them for those
%   in the function file, making it easier to adjust one or two options on
%   a run by run basis.
%function FeatureExtractionModule(varargin)

    if nargin == 1
      alt_config = varargin{1};
    else
      alt_config = [];
    end
    %%%%% Main Variables

    config_ops = cbir_config(alt_config);
    %%% Global settings
    numSegments = config_ops.numSegments;
    sizeSegments = 1/numSegments;
    numCells = numSegments*numSegments;
    dataSet = config_ops.dataSet;
    exten = config_ops.extension;
    datasetDir = config_ops.datasetDir;
    outputDir = config_ops.outputDir;
    if ~exist(outputDir,'dir')
        mkdir(outputDir);
    end
    imgFeatureNames = config_ops.imgFeatureNames;
    imgFeatureFunctions = config_ops.imgFeatureFunctions;
    imgFeatureFuncParams = config_ops.imgFeatureFuncParams;
    FDPath = config_ops.FDPath;
    imageClassLabelsPath = config_ops.imageClassLabelsPath;
    imagesfile = config_ops.imageListFile;
    useFile = config_ops.useFile;
    writeFeatureImages = config_ops.FE_writeFeatureImages;
    %%% FE specific settings
    featureDataOverwrite = config_ops.FE_featureDataOverwrite;    %1 for extracting features
    wekaWrite_fullFD = config_ops.FE_wekaWrite_fullFD;%1 for writing weka files for classification
    wekaWrite_singleFeature = config_ops.FE_wekaWrite_singleFeature;
    readFunction=config_ops.FE_readFunction;
    readFunctionParameters = config_ops.FE_readFunctionParameters;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%% End of configuration
    %%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% data setup
    if ~useFile
      %% build list of images and class labels from directory structure
      %% assumed format is
      %%
      %% top folder (datasetDir)
      %%   folder named after class A
      %%     image of class A
      %%     image of class A
      %%   folder named after class B
      %%     image of class B
      %%     image of class B
      %%   etc.
      %%
      if ~exist(datasetDir,'dir')
         error('Input directory not found:\n\t%s ',datasetDir);
      end
      classes = dir(datasetDir);
      classes = classes([classes.isdir]) ;
      classes = {classes(3:end).name}; % first two are always '.' and '..';
      imageFileNames = {} ;
      imageClassLabels = {} ;

      for ci = 1:length(classes)% for each class/folder
        classIms = dir(fullfile(datasetDir, classes{ci}, ['*.' exten]));
        classIms = cellfun(@(x)fullfile(datasetDir,classes{ci},x),{classIms.name},'UniformOutput',false);
        imageFileNames = [imageFileNames, classIms]; %#ok<AGROW>
        imageClassLabels{end+1} = repmat(classes(ci), 1,length(classIms)); %#ok<AGROW>
      end
      imageClassLabels = cat(2, imageClassLabels{:});
    else
     %% build List of classes from file list
      disp('importing image list from file');
      f = fopen(imagesfile);
      M = textscan(f,'%s','Delimiter','\n');
      fclose(f);
      M = M{1};
      imageFileNames = M(1:2:end);
      imageClassLabels = M(2:2:end);
      classes = unique(imageClassLabels);
    end
    numImages = length(imageFileNames);
    % save imageClassLabels so we can access it from other modules
    save(imageClassLabelsPath,'imageClassLabels');

    % if the output of an image function is more than one value, we need to
    % accomodate that in our data structure
    testimage = rand(100,100);
    expandedImageFeatures = {};
    for featureValueNum = 1:length(imgFeatureNames)
      value =  imgFeatureFunctions{featureValueNum}(testimage,imgFeatureFuncParams{featureValueNum}{:});
      l = length(value);
      if l > 1
        nums = cellfun(@num2str,num2cell(1:l),'UniformOutput',false);
        repImageFeatNames = repmat(imgFeatureNames(featureValueNum),[1 l]);
        expandedSingleImageFeature = cellfun(@strcat,repImageFeatNames,nums,'UniformOutput', false);
      else
        expandedSingleImageFeature = imgFeatureNames(featureValueNum);
      end
      expandedImageFeatures = cat(2,expandedImageFeatures,expandedSingleImageFeature);
      numFeatureValues = length(expandedImageFeatures);
    end

    disp('data set up')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Extract the image features
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % first try to load from computed files
    if(exist(FDPath,'file')) && ~featureDataOverwrite
        disp('loading feature data');
        load(FDPath);
        disp('data loaded');
    else
        disp('calculating feature values');
        FD = zeros(numImages,numCells,numFeatureValues);
        for imageNum = 1:numImages
            completeFileLocation = fullfile(imageFileNames{imageNum});
            I = readFunction(completeFileLocation,readFunctionParameters{:});

            % Break image into grid-based cells
            imageInfo = imfinfo(completeFileLocation); % read image info
            im_y=imageInfo.Height;
            im_x=imageInfo.Width;
            chunkX = round(im_x*sizeSegments); %x size of a grid cell
            chunkY = round(im_y*sizeSegments); %y size of a grid cell
            moveX = (im_x-chunkX)/(numSegments-1);
            moveY = (im_y-chunkY)/(numSegments-1);

            % go through each cell of the image, and calculate the features
            x=1;
            y=1;
            x2=chunkX;
            y2=chunkY;
            cellCounter = 0;
            for iRow=1:numSegments %rows 
              for iCol=1:numSegments  %columns
                cellCounter = cellCounter +1;
                cellRange=I(y:y2,x:x2);
                featureCounter = 1;
                for featureValueNum = 1:length(imgFeatureNames)
                  if numel(cellRange) >0
                    value =  imgFeatureFunctions{featureValueNum}(cellRange,imgFeatureFuncParams{featureValueNum}{:});
                    FD(imageNum,cellCounter,featureCounter:featureCounter+length(value)-1) = value;
                    featureCounter = featureCounter+length(value);
                  else
                    FD(imageNum,cellCounter,featureValueNum) = 0;
                    disp('zero area extraction cell encountered')
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
        save(FDPath,'FD');
        disp('Image Feature Extraction Done...');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%
    %% write feature images
    %%%%%%%%%%%%%%%%%%%%%%%%%
    skips = 0;
    if writeFeatureImages ~= runStatus.skip
      numDigits = ceil(log10(numImages));
      numDigits = num2str(numDigits);
      FeatureImageBaseFolder = fullfile(outputDir,'FeatureImages');
      if ~exist(FeatureImageBaseFolder,'dir')
        mkdir(FeatureImageBaseFolder);
      end
      disp('writing feature images');



      for featureNum = 1:length(imgFeatureNames) % for each feature
        featureName = imgFeatureNames{featureNum}; % 
        Y = squeeze(FD(:,:,featureNum));

        featureWekaAttributeNames = max(Y(:));
        count = 1; % count will enumerate all images in all classes with distinct numbers
        for imageNum = 1: size(FD,1) % for each image
          I = squeeze(Y(imageNum,:));
          class_I = imageClassLabels{imageNum};
          I = reshape(I,[numSegments numSegments])';
          I = I/featureWekaAttributeNames;

          FeatImClassFolder = fullfile(FeatureImageBaseFolder,featureName,['class ',class_I]);
          if ~exist(FeatImClassFolder,'dir')
            mkdir(FeatImClassFolder);
          end

          filepath = fullfile(FeatImClassFolder,[sprintf(['%0',numDigits,'d'],count),'.png']);
          if ~exist(filepath,'file') || writeFeatureImages == runStatus.overwrite 
            numColors = 64;
            I = quickscaleImage(I);
            I = normToZeroX(I,numColors);
            imwrite(I,jet(numColors),filepath,'png');
          else
              skips = skips+1;
          end
          count = count +1;
        end
      end
      if skips >0
          fprintf(1,'%d feature images skipped due to already existing\n',skips);
      end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%
    %% Weka writing
    %%%%%%%%%%%%%%%%%%%%%%%%
    if wekaWrite_fullFD ~= runStatus.skip
        disp('writing weka for full feature data')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Use the Feature Data structure
    %%%% to build weka data (ARFF) structure
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        allFeaturesWekatitle = sprintf('%s-%dx%d-%s',dataSet,numSegments,numSegments,'ALLFEATURES');
        arffFilename=fullfile(outputDir,[allFeaturesWekatitle,'.arff']);
        allWekaAttributeNames = {};
        if ~exist(arffFilename,'file') || wekaWrite_fullFD == runStatus.overwrite 
            imageWekaData = cell(numImages,1);
            for imageNum = 1:numImages
              %each row of the data is an image
                featureWekaData = cell(numFeatureValues);
                for featureValueNum = 1:numFeatureValues
                    if imageNum == 1
                        %% create the list of weka attribute names
                        % each feature-value-cell combination is a different weka
                        % attribute
                        filepath = expandedImageFeatures(featureValueNum);
                        FeatureNameRep = repmat(filepath,[1,numCells*numFeatureValues]);
                        cRep = repmat({'c'},[1,numCells*numFeatureValues]);

                        cellNumbers = arrayfun(@num2str,1:numCells,'unif',0);
                        cellNumbersRep = repmat(cellNumbers,[1,numFeatureValues]);

                        featureWekaAttributeNames = cellfun(@strcat,FeatureNameRep,cRep,cellNumbersRep,'UniformOutput',false);
                        allWekaAttributeNames = cat(2,allWekaAttributeNames,featureWekaAttributeNames);
                    end
                    featureValueForAllCells = cat(2,FD(imageNum,:,featureValueNum));
                    featureWekaData{featureValueNum} = featureValueForAllCells;
                end
              imageWekaData{imageNum} = cat(2,featureWekaData{:});
            end % end of images loop;
            wekaData = cat(1,imageWekaData{:});
            writeWeka(arffFilename,'derp',allWekaAttributeNames,classes,wekaData,imageClassLabels)
        else
            disp('all feature weka already created')
        end
    end
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% make ARFF for each feature
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if wekaWrite_singleFeature ~= runStatus.skip
        disp('writing weka for individual feature data')
        for featureValueNum = 1:numFeatureValues
          individualFeatureWekatitle = sprintf('%s-%dx%d-%s',dataSet,numSegments,numSegments,expandedImageFeatures{featureValueNum});
          featArffFilename = fullfile(outputDir,[individualFeatureWekatitle,'.arff']);
          if ~exist(featArffFilename,'file') || wekaWrite_singleFeature == runStatus.overwrite 
            imageWekaData = cell(numImages,1);
            for imageNum = 1:numImages
              %each row of the data is an image
              featureValueForAllCells = cat(2,FD(imageNum,:,featureValueNum));
              if imageNum == 1 % if this is the first image
                %%%% create the list of weka attribute names
                filepath = expandedImageFeatures(featureValueNum);
                FeatureNameRep = repmat(filepath,[1,numCells]);
                cRep = repmat({'c'},[1,numCells]);

                cellNumbers = arrayfun(@num2str,1:numCells,'UniformOutput',false);

                featureWekaAttributeNames = cellfun(@strcat,FeatureNameRep,cRep,cellNumbers,'UniformOutput',false);
                %%%%
              end
              imageWekaData{imageNum} = featureValueForAllCells;
            end % end of images loop;
            wekaData = cat(1,imageWekaData{:});
            writeWeka(featArffFilename,'derp',featureWekaAttributeNames,classes,wekaData,imageClassLabels)
          else
            fprintf('%s individual weka already created\n',expandedImageFeatures{featureValueNum});
          end
        end % end individual feature loop 
    end % end single feature ARFF creation
    disp('Feature Extraction Module has completed. Check your output folder for results')

    function I2 = quickscaleImage(I)
        % goal is ~512x512 pixels
        Isize = size(I);
        Inumpix = numel(I);
        scale = round(sqrt(512*512/Inumpix));
        I2 = zeros(Isize*scale);
        for ii = 1:Isize(1)
            for jj = 1:Isize(2)
                I2(scale*(ii-1)+1:scale*(ii-1)+scale,scale*(jj-1)+1:scale*(jj-1)+scale) = I(ii,jj);
            end
        end
    end
    function I2 = normToZeroX(I,x)
        Imax = max(I(:));
        Imin = min(I(:));
        I2 = (I-Imin)/(Imax-Imin)*x;
    end
end % function



