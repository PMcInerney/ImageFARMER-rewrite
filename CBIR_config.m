function outfile = CBIR_config(varargin)
if nargin == 0
  alt_config = [];
elseif nargin == 1
  alt_config = varargin{1};
  if ~isstruct(alt_config)
    error('Input must be struct');
  end
else
    error('Too many input arguments');
end

outfile = struct();
%% Non-derived Settings
%%%%%%%%%%%%%%%%%%%%
%% General Settings
%%%%%%%%%%%%%%%%%%%%
outfile.useFile = false;
outfile.numSegments=8;                       %Number of Columns/rows  NbyN
outfile.sizeSegments = 1/outfile.numSegments;        %size (in fraction of image dimension) of each segment. large sizes will cause segments to overlap
outfile.numCells=outfile.numSegments*outfile.numSegments;
                                             %Grid Cell Size
outfile.dataSet='CLEFMED05';                 %Dataset Being Manipulated           
outfile.dataSetForPlots=strrep(outfile.dataSet,'_','\_');                 %Dataset Being Manipulated           
outfile.exten='png';                         %extension of dataset images
outfile.datasetDir='';                       %The root folder of a dataset 
outfile.outputDir='';                        %base folder of outputs

outfile.imgFeatureNames={'mean','stdDev','skewness','kurtosis','entropy','FracDim','TamCon','TamDir','RS','Uniformity'};
                                             %Image Parameter List
outfile.imgFeatureFunctions={@mean2,@std2,@my3rdM, @my4thM, @entropy, @myFracDim,@MyTamCon,@MyTamDir,@myRS,@myUniformity};
outfile.imgFeatureFuncParams={{} {} {} {} {} {} {} {} {} {}};
outfile.imageListFile = 'doesnt exist' ;
outfile.numFeatures=length(outfile.imgFeatureFunctions);
                                             %Number of Image Parameters
outfile.FDSize=outfile.numSegments*outfile.numSegments*outfile.numFeatures; 
                                             %Number of elements in the Feature Vector
outfile.FDPath = fullfile(outfile.outputDir,'FD.mat');
outfile.imageClassLabelsPath = fullfile(outfile.outputDir,'CL.mat');

%%  module specific settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Feature Extraction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outfile.FE_featureDataOverwrite=false; % this will force the recalculation of feature data, even if it's already been extracted. Otherwise, the data will be loaded from the existing extraction
outfile.FE_wekaWrite_fullFD=runStatus.runIfMissing;
outfile.FE_wekaWrite_singleFeature = runStatus.runIfMissing;    %
outfile.FE_writeParameterImages = runStatus.runIfMissing;
outfile.FE_arffFilename = fullfile(outfile.outputDir,[outfile.dataSet '.arff']);
outfile.FE_readFunction = @imread;             % this can be changed if we want to read from text files instead of images
outfile.FE_readFunctionParameters = {};
outfile.FE_fastParameterImages = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Attribute Evaluation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outfile.AE_outputDir = fullfile(outfile.outputDir,'AE');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Dissimilarity Measures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For details on these measures please refer to Juan M. Banda's
% Ph.D dissertation available at: http://www.jmbanda.com
outfile.DM_distanceNames={'euclidean' 'seuclidean' 'mahalanobis' 'cityblock' 'cosine' 'correlation' 'spearman' 'chebychev' 'hausdorff' 'KLD' 'JSD' 'CHI2'};
                                               %the names of the different distances used
outfile.DM_distanceFunctions={'euclidean','seuclidean','mahalanobis','cityblock','cosine','correlation','spearman','chebychev',@my_haus,@my_KLDSym,@my_JSD,@my_CH2};
outfile.DM_distanceFuncParams={{} {} {} {} {} {} {} {} {} {}};

outfile.DM_numDistances = length(outfile.DM_distanceFunctions);                     %number of distances used for similarity comparisons
outfile.DM_tang_thres= 135;                    %tangent angle thresholding for components
outfile.DM_component_thresholds=10;            %flat component thresholds. can use array to run multiple
outfile.DM_plot = runStatus.runIfMissing;                           %0 for plots , true for no plots
outfile.DM_weka_write = runStatus.runIfMissing;                     %0 for no weka writing, true for weka writing 
outfile.DM_outputFolder = fullfile(outfile.outputDir,'DM');
% this colors are picked for good contrast. If more than 12 classes are
% being viewed via MDS, other data will need to be provided.
% the spaces are important, due to how these are concatenated
outfile.DM_MDS_plotColors = [
66,206,227;
31,120,180;
178,223,138;
51,160,44;
251,154,153;
227,26,28;
253,191,111;
255,127,0;
202,178,214;
106,61,154;
255,255,153;
177,89,40];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Dimensionality reduction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outfile.DR_plt = runStatus.skip;
outfile.DR_weka_write = runStatus.runIfMissing;
outfile.DR_methodNames={'PCA','SVD','KernelPCA','FactorAnalysis','LLE','Laplacian','Isomap','LPP'};
outfile.DR_functions={@myPCA,@mySVD,@myKPCA,@myFA,@myLLE,@myLaplacian,@myIsomap,@myLPP};
outflie.DR_outputDir = fullfile(outfile.outputDir,'DR');
outfile.DR_skipRCONDWarnings = true; 
% certain DR techniques (like Factor Analysis) tend to produce a lot of
% these warnings on some datasets. Although this probably indicates that the data isn't
% working with the technique well, which is good to know, that information
% can overwhelm other outputs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Handle alternative config options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 1 % if alt_config provided
    alt_config_fieldnames = fieldnames(alt_config);
    for j = 1:size(alt_config_fieldnames,1)
        if isfield(outfile,alt_config_fieldnames{j})                         % if the alternate config privides a replacement for config option
            outfile.(alt_config_fieldnames{j}) = alt_config.(alt_config_fieldnames{j});    % use it instead of default
        else
            warning('alt_config field ''%s'' is not a valid configuration field. Ignoring...',alt_config_fieldnames{j});
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%handle 'derived' options
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if we didn't explicitly override a derived option
    % derive it again
    % this is an imperfect option, but there isn't an easy alternataive
    if ~isfield(alt_config,'sizeSegments')
        outfile.sizeSegments = 1/outfile.numSegments;        %size (in fraction of image dimension) of each segment. large sizes will cause segments to overlap
    end

    if ~isfield(alt_config,'numFeatures')                     
        outfile.numFeatures = length(outfile.imgFeatureFunctions);
    end

    if ~isfield(alt_config,'dataSetForPlots')                     
        outfile.dataSetForPlots=strrep(outfile.dataSet,'_','\_');
    end

    if ~isfield(alt_config,'FVSize')
        outfile.FVSize=outfile.numSegments*outfile.numSegments*outfile.numFeatures;
    end

    if ~isfield(alt_config,'FDPath')
        outfile.FDPath = fullfile(outfile.outputDir,'FD.mat');
    end

    if ~isfield(alt_config,'imageClassLabelsPath')
        outfile.imageClassLabelsPath = fullfile(outfile.outputDir,'CL.mat');
    end

    if ~isfield(alt_config,'numCells')
        outfile.numCells=outfile.numSegments*outfile.numSegments;
    end

    if ~isfield(alt_config,'DM_numDistances')
        outfile.DM_numDistances = length(outfile.DM_distanceFunctions);                     %number of distances used for similarity comparisons
    end

    if ~isfield(alt_config,'DM_outputFolder')
        outfile.DM_outputFolder = fullfile(outfile.outputDir,'DM');
    end

    if ~isfield(alt_config,'AE_outputDir')
        outfile.AE_outputDir = fullfile(outfile.outputDir,'AE');
    end

    if ~isfield(alt_config,'DR_outputDir')
        outfile.DR_outputDir = fullfile(outfile.outputDir,'DR');
    end
end