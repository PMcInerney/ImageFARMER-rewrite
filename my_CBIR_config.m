function outfile = my_CBIR_config(varargin)
if nargin == 1     
  alt_config = varargin{1};     
else
  alt_config = [];                
end

outfile = struct();
%% Non-derived Settings
%%%%%%%%%%%%%%%%%%%%
%% General Settings
%%%%%%%%%%%%%%%%%%%%
outfile.useFile = false;
outfile.numClasses=8;
                                             %Number of classes
outfile.classSize=200;                       %class size (number of images in each folder)
outfile.totalImageCount=outfile.numClasses*outfile.classSize;
                                             %total number of images
outfile.numSegments=8;                       %Number of Columns/rows  NbyN
outfile.sizeSegments = 1/outfile.numSegments;        %size (in fraction of image dimension) of each segment. large sizes will cause segments to overlap
outfile.numCells=outfile.numSegments*outfile.numSegments;
                                             %Grid Cell Size
outfile.dataSet='CLEFMED05';                 %Dataset Being Manipulated           
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
outfile.singleParamClassification = true;    %

outfile.FVSize=outfile.numSegments*outfile.numSegments*outfile.numFeatures; 
                                             %Number of elements in the Feature Vector
outfile.FVPath = fullfile(outfile.outputDir,'FV.mat');
outfile.imageClassLabelsPath = fullfile(outfile.outputDir,'CL.mat');

%%  module specific settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Feature Extraction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outfile.FE_param_vis=0;                        %0 for no Visualization, 1 for visualization
outfile.FE_feat_ext=1;                         %0 for no feature extraction, 1 for feature extraction
outfile.FE_weka_write=0;                       %0 for no weka writing, 1 for weka writing
outfile.FE_writeParameterImages = false;
outfile.FE_arffFilename = fullfile(outfile.outputDir,[outfile.dataSet '.arff']);
outfile.FE_readFunction = @imread;             % this can be changed if we want to read from text files instead of images
outfile.FE_readFunctionParameters = {};

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
outfile.DM_plot = 1;                           %0 for plots , 1 for no plots
outfile.DM_weka_write = 1;                     %0 for no weka writing, 1 for weka writing 
outfile.DM_outputFolder = fullfile(outfile.outputDir,'DM');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Dimensionality reduction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outfile.DR_plt = 0;                            %1 for plots , 0 for no plots
outfile.DR_weka_write = 1;                     %1 for weka writing, 0 for weka writing      
outfile.DR_methodNames={'PCA','SVD','KernelPCA','FactorAnalysis','LLE','Laplacian','Isomap','LPP'};
outfile.DR_functions={@myPCA,@mySVD,@myKPCA,@myFA,@myLLE,@myLaplacian,@myIsomap,@myLPP};
outflie.DR_outputDir = fullfile(outfile.outputDir,'DR');

%%%%%%%%%%%%%%%
%%Indexing
%%%%%%%%%%%%%%%
outfile.IM_plt = 0;                            %1 for plots , 0 for no plots
outflie.IM_outputDir = fullfile(outfile.outputDir,'IM');
outfile.IM_ALL_DIM= 0;
outfile.DIM_RED= 0;   %1 yes, 0 no
outfile.DIM_RED_T= 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Handle alternative config options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if alt_config
    alt_config_fieldnames = fieldnames(alt_config);
    for j = 1:size(alt_config,1)
        if isfield(outfile,alt_config_fieldnames{j})                         % if the alternate config privides a replacement for config option
            outfile.(alt_config_fieldnames{j}) = alt_config.(alt_config_fieldnames{j});    % use it instead of default
        else
            fprintf(1,'alt_config field ''%s'' is not a valid configuration field. Ignoring\n',alt_config_fieldnames{j});
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

    if ~isfield(alt_config,'numParameters')                     
        outfile.numParameters = length(outfile.imgParameters);   
    end

    if ~isfield(alt_config,'FVSize')
        outfile.FVSize=outfile.numSegments*outfile.numSegments*outfile.numParameters;
    end

    if ~isfield(alt_config,'FVPath')
        outfile.FVPath = fullfile(outfile.outputDir,'FV.mat');
    end

    if ~isfield(alt_config,'imageClassLabelsPath')
        outfile.imageClassLabelsPath = fullfile(outfile.outputDir,'CL.mat');
    end

    if ~isfield(alt_config,'totalImageCount')
        outfile.totalImageCount=outfile.numClasses*outfile.classSize;
    end

    if ~isfield(alt_config,'numCells')
        outfile.numCells=outfile.numSegments*outfile.numSegments;
    end

    if ~isfield(alt_config,'FE_arffFilename')
        outfile.FE_arffFilename = fullfile(outfile.outputDir,[outfile.dataSet '.arff']);
    end

    if ~isfield(alt_config,'DM_numDistances')
        outfile.DM_numDistances = length(outfile.DM_distanceFunctions);                     %number of distances used for similarity comparisons
    end

    if ~isfield(alt_config,'DM_outputFolder')
        outfile.DM_outputFolder = fullfile(outfile.outputDir,'DM');
    end

    if ~isfield(alt_config,'DR_outputDir')
        outfile.DR_outputDir = fullfile(outfile.outputDir,'DR');
    end

    if ~isfield(alt_config,'IM_outputDir')
        outfile.DR_outputDir = fullfile(outfile.outputDir,'IM');
    end
end