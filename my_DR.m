%% Dimensionality Reduction Module (DRM) Demo
%    Copyright (C) 2012  Juan M. Banda, Rafal A. Angryk from Montana State University
%    Contact: juan@jmbanda.com
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
% MORE INFO
%  Stand-alone script to ilustrate the usage of the Feature Extraction
%  Module. Remember to set your path to the correct place where the demo
%  subset of the dataset has been extracted
%  For more details
%  Juan M. Banda's dissertation:
%  "FRAMEWORK FOR CREATING LARGE-SCALE CONTENT-BASED IMAGE RETRIEVAL SYSTEM
%  (CBIR) FOR SOLAR DATA ANALYSIS"
%  http://www.jmbanda.com/Dissertation/
%
%  Notes on this DEMO:
%  http://www.jmbanda.com/Framework/Demo/
function my_DR(varargin)

    if nargin == 1
      alt_config = varargin{1};
    else
      alt_config = [];
    end
    conf = my_CBIR_config(alt_config);
    %%%%Global settings
    TotalImageCount = conf.totalImageCount;
    numSegments = conf.numSegments;
    dataSet = conf.dataSet;
    DR_outputDir = conf.DR_outputDir;
    if ~exist(DR_outputDir,'dir')
        mkdir(DR_outputDir);
    end
    FVPath = conf.FVPath;
    imageClassLabelsPath = conf.imageClassLabelsPath;
    DR_functions = conf.DR_functions;
    DR_methodNames = conf.DR_methodNames;
    %%%%Local Settings

    plt=conf.DR_plt;                           %1 for plots , 0 for no plots
    weka_write=conf.DR_weka_write;             %1 for weka writing, 0 for weka writing


    %%%%%%%%%%%%%%%%%%%%%% END OF GLOBAL VARIABLES
    %% Get Data from the FE files to manipulate
    %%FV is (image, parameter, cell)
    [FV,imageClassLabels] = loadData(FVPath,imageClassLabelsPath);
    classNames = unique(imageClassLabels);
    %% Dimensionality Estimation (via PCA and SVD Components)
    %This will produce an 8 element vector with the four PCA dimensional
    %targets (from 96 to 99% of variance) and the four SVD dimensional targets
    %(from 96 to 99% of variance)
    %Example: target_dimensions=[ PCA # of components with 96% of variance,
    %PCA # of components with 97% of variance, etc, etc]

    % reshape FV from (image,parameter,cell) to (im,cell-param)
    derp = permute(FV,[1,3,2]);
    sizederp = size(derp);
    FE_data = reshape(derp,sizederp(1),sizederp(2)*sizederp(3));

    %% Estimate how many dimensions are appropraite
    target_dimensions=zeros(1,8); %this stores 8 target dimensions (4 for PCA, 4 for SVD)
    dim_counter=1;

    methods = {'PCA','SVD'};
    for ii = 1:2
      method = methods{ii};
      %calculate variances
      if strcmp(method,'PCA')
        [~,~,latent,~] = princomp(FE_data);
        Variance=cumsum(latent)./sum(latent);
      end
      if strcmp(method,'SVD')
        [~,S,~] = svd(zscore(FE_data),'econ');
        variances = diag(S).^2 / (size(FE_data,1)-1);
%         varExplained = 100 * variances./sum(variances);
        Variance=cumsum(variances)./sum(variances);    %base 100
      end
      for threshold = 96:99
        target_dimensions(dim_counter) = find(Variance >= threshold/100,1); % use find to get first dimension count that hits threshold
        dim_counter=dim_counter+1;
      end
      if plt
        figure(2);
        set(2, 'Visible', 'off');
        plot(Variance,'DisplayName','Variance','YDataSource','Variance');
        plotTitle = strcat(method,' Component Variance for ALL Dataset-',dataSet);
        plotFilename = strcat(plotTitle,'-',int2str(numSegments),'x',int2str(numSegments));
        plotFilePath = fullfile(ouputFolder,plotFilename);
        title(plotTitle);        
        saveas(2,plotFilePath,'jpg');
        close(2);

        figure(3);
        set(3, 'Visible', 'off');
        if strcmp(method,'PCA')
          variances = latent;
        end
        %You can easily calculate the percent of the total variability
        %explained by each principal component.
        percent_explained = 100*variances/sum(variances);
        pareto(percent_explained)
        xlabel('Principal Component')
        ylabel('Variance Explained (%)')
        plotTitle = strcat('PCA percent of the total variability explained by each principal component for ',...
                           'ALL',' Dataset-',dataSet);
        plotFilename=strcat(plotTitle,'-',int2str(numSegments),'x',int2str(numSegments));
        plotFilePath = fullfile(ouputFolder,plotFilename);
        title(plotTitle);
        saveas(3,plotFilePath,'jpg');
        close(3);
      end
    end
    fprintf(1,'Targeted dimensions for experimentation: %s\n\n', num2str(target_dimensions));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%End of dimensionality estimation%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Splitting the dataset in 67 - 33% samples
    % this code splits the dataset by taking every third image as a test
    % image, and the rest as training. This may not be appropriate for 
    % all possible datasets
    
    % Normalize before separating
    FE_data = bsxfun(@rdivide,FE_data,sum(FE_data,2)); % each parameter is normalized to sum to one across the dataset
    FE_data(FE_data==0) = 0.000000000000000000000001;  % avoid zeros

    TestIndices = boolean(zeros(1,TotalImageCount));
    TestIndices(3:3:end) = 1;
    TrainIndices = ~TestIndices;

    TrainSet = FE_data(TrainIndices,:);
    TestSet = FE_data(TestIndices,:);

    labelsDataTrain = imageClassLabels(TrainIndices);
    labelsDataTest = imageClassLabels(TestIndices);


    %% Actual dimensionality reduction
    for numDims=target_dimensions  %Loop through the targeted dimensions
        for DR_method_num = 1:length(DR_functions) % Loop through dimensionality reduction techniques
            skip = 0;
            try
                [mappedX,t_points] =  DR_functions{DR_method_num}(TrainSet,TestSet,numDims);
            catch E
                fprintf(1,'dimensionality reduction for %s with %d dimensions failed. Skipping output\n\n',DR_methodNames{DR_method_num},numDims);
                fprintf(1,'error message:\n%s\n\n',E.message);
                skip = 1;
            end
%                 msg=char(strcat('LPP-',num2str(no_dimsEV),' failed because number of dimensions exceeds number of samples'))
%                 skip=1;
            %% OUTPUT TO WEKA
            if weka_write && ~skip
                NumberDRComps=numDims;
                DRParamNames = arrayfun(@num2str, 1:NumberDRComps, 'unif', 0); % just use 1,2,... for parameter names
                %% WEKA Writing for Train set
                wekaTitle=sprintf('67-33-%s-%s Components Training N-%d-Feature-All-%dx%d',dataSet,DR_methodNames{DR_method_num},NumberDRComps,numSegments,numSegments);
                wekaFilePath=fullfile(DR_outputDir,[wekaTitle,'.arff']);
                myWriteWeka(wekaFilePath,wekaTitle,DRParamNames,classNames,mappedX,labelsDataTrain)
                %% WEKA Writing for Test set 
                wekaTitle=sprintf('67-33-%s-%s Components Test N-%d-Feature-All-%dx%d',dataSet,DR_methodNames{DR_method_num},NumberDRComps,numSegments,numSegments);
                wekaFilePath=fullfile(DR_outputDir,[wekaTitle,'.arff']);
                myWriteWeka(wekaFilePath,wekaTitle,DRParamNames,classNames,t_points,labelsDataTest)
            end %Weka write skipping
        end %Reduction Methods loop
    end % Dimensions Loop
    disp('Dimensionality Reduction Module Demo has been completed. Check your output folder for results')
end % end function
