%    ImageFARMER-rewrite Configuration Function
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
% Config_ops = CBIR_config()
%   Returns a struct containing configuration settings for the
%   IMAGEFarmer-Rewrite CBIR building framework.
%
%   It is intended that users may edit the function file to adjust the
%   'default' configuration options if they choose.
%   
%   Config_ops = CBIR_config(alt_config) takes any valid configuration 
%   fields provided in the struct alt_config and substitutes them for those
%   in the function file, making it easier to adjust one or two options on
%   a run by run basis.
function outfile = cbir_config(varargin)

%% argument processing
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
%%%%%%%%%%%%%%%%%%%%
%% Global Settings
%%%%%%%%%%%%%%%%%%%%
outfile.useFile = false;
outfile.numSegments=8;                       %Number of Columns/rows  NbyN
outfile.dataSet='CLEFMED05';                 %Dataset Being Manipulated           
outfile.dataSetForPlots=strrep(outfile.dataSet,'_','\_');                 %Dataset Being Manipulated           
outfile.extension='png';                         %extension of dataset images
outfile.datasetDir='';                       %The root folder of a dataset 
outfile.outputDir='';                        %base folder of outputs

outfile.imgFeatureNames={'mean','stdDev','skewness','kurtosis','entropy','TamCon','TamDir','RS','Uniformity'};
                                             %Image Feature List
outfile.imgFeatureFunctions={@mean2,@std2,@wrapped3rdM, @wrapped4thM, @entropy,@TamuraContrast,@TamuraDirectionality,@RelSmooth,@Uniformity};
outfile.imgFeatureFuncParams={{} {} {} {} {} {} {} {} {} {}};
outfile.imageListFile = 'doesnt exist' ;
outfile.numFeatures=length(outfile.imgFeatureFunctions);
                                             %Number of Image Features
outfile.FDPath = fullfile(outfile.outputDir,'FD.mat');
outfile.imageClassLabelsPath = fullfile(outfile.outputDir,'CL.mat');

%%  Module Specific settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Feature Extraction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outfile.FE_featureDataOverwrite=false; % this will force the recalculation of feature data, even if it's already been extracted. Otherwise, the data will be loaded from the existing extraction
outfile.FE_wekaWrite_fullFD=runStatus.runIfMissing;
outfile.FE_wekaWrite_singleFeature = runStatus.runIfMissing;    %
outfile.FE_writeFeatureImages = runStatus.runIfMissing;
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
outfile.DM_distanceFunctions={'euclidean','seuclidean','mahalanobis','cityblock','cosine','correlation','spearman','chebychev',@haus,@KLDSym,@JSD,@CH2};
outfile.DM_distanceFuncParams={{} {} {} {} {} {} {} {} {} {}};

outfile.DM_tang_thres= 135;                    %tangent angle thresholding for components
outfile.DM_component_thresholds=10;            %flat component thresholds. can use array to run multiple
outfile.DM_plot = runStatus.runIfMissing;
outfile.DM_wekaWrite = runStatus.runIfMissing;
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
outfile.DR_plotDimensionSelection = runStatus.skip;
outfile.DR_varianceThresholds = 96:99; %percentage of variance used to 
% pick number of dimensions to reduce to. using an array here will cause
% multiple separate reductions, each producing separate outputs.
outfile.DR_fixedDimensions = [];
outfile.DR_wekaWrite = runStatus.runIfMissing;
outfile.DR_methodNames={'PCA','SVD','KernelPCA','FactorAnalysis','LLE','Laplacian','Isomap','LPP'};
outfile.DR_functions={@wrappedPCA,@wrappedSVD,@wrappedKPCA,@wrappedFA,@wrappedLLE,@wrappedLaplacian,@wrappedIsomap,@wrappedLPP};
outfile.DR_outputDir = fullfile(outfile.outputDir,'DR');
outfile.DR_skipRCONDWarnings = true;
% certain DR techniques (like Factor Analysis) tend to produce a lot 
% 'ill-conditioned matrix' warnings on some datasets. Although this 
% probably indicates that the data isn't
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
    if ~isfield(alt_config,'numFeatures')                     
        outfile.numFeatures = length(outfile.imgFeatureFunctions);
    end

    if ~isfield(alt_config,'dataSetForPlots')                     
        outfile.dataSetForPlots=strrep(outfile.dataSet,'_','\_');
    end

    if ~isfield(alt_config,'FDPath')
        outfile.FDPath = fullfile(outfile.outputDir,'FD.mat');
    end

    if ~isfield(alt_config,'imageClassLabelsPath')
        outfile.imageClassLabelsPath = fullfile(outfile.outputDir,'CL.mat');
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