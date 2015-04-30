%    ImageFARMER-Rewrite  Attribute Evaluation Module
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
%  AttributeEvaluationModule()
%   Runs the Attribute Evaluation Module of the
%   IMAGEFarmer-Rewrite CBIR building framework.
%
%   AttributeEvaluationModule(alt_config) takes any valid configuration 
%   fields provided in the struct alt_config and substitutes them for those
%   in the function file, making it easier to adjust one or two options on
%   a run by run basis.
%

function AttributeEvaluationModule(varargin)

%% Configuration
    if nargin == 1
      alt_config = varargin{1};
    else
      alt_config = [];
    end

    % Global Configuration options
    config_ops = cbir_config(alt_config);
    numFeatures = config_ops.numFeatures;
    dataSet = config_ops.dataSet;
    dataSetForPlots = config_ops.dataSetForPlots;
    FDPath = config_ops.FDPath;
    imageClassLabelsPath = config_ops.imageClassLabelsPath;
    imgFeatureNames = config_ops.imgFeatureNames;
    [FD, imageClassLabels] = loadData(FDPath,imageClassLabelsPath);
    classNames = unique(imageClassLabels);
    numClasses = length(classNames);
    
    % AE specific configuration options
    AE_outputDir = config_ops.AE_outputDir;
    if ~exist(AE_outputDir,'dir')
        mkdir(AE_outputDir);
    end
    % end of configuration

    %% Calculate average between-image correlation
    averageCorrelation = zeros(numClasses,numFeatures,1); % the average correlation among values of a single feature for a single class
    for classCounter = 1:numClasses
        % pick out all the images for a class
        className = classNames(classCounter);
        classNameRep = repmat(className,size(imageClassLabels));
        classIndices = cellfun(@strcmp,classNameRep,imageClassLabels);
        classSize = sum(classIndices);
        for feat=1:numFeatures %for each feature
            imageCorrelations = pdist(FD(classIndices,:,feat),'correlation');
            averageCorrelation(classCounter,feat) = 2*sum(imageCorrelations)/classSize^2; % calculate mean distance of non-squareform distance matrix
        end
    end

    %% Make and save the intra class plots
    for classCounter = 1:numClasses
        singleClassCorrelation = averageCorrelation(classCounter,:);
        intraCorrMat = squareform(pdist(singleClassCorrelation(:)));
        intraCorrDistMat = 1-intraCorrMat;
        savePlot('IntraClass',classCounter,intraCorrDistMat)
    end
    %% Make and save the inter class plots
    derp = zeros(numClasses,numFeatures,numClasses);
    for feat = 1:numFeatures
        featureCorrelation = averageCorrelation(:,feat);
        derp(:,feat,:) = squareform(pdist(featureCorrelation(:)));
    end
    classCompare = mean(derp,3);
    for classCounter = 1:numClasses
        X = classCompare(classCounter,:);
        interCorrMat = squareform(pdist(X(:)));
        interCorrDistMat = 1-interCorrMat;
        savePlot('InterClass',classCounter,interCorrDistMat)
    end
%% and we're done
    disp('Attribute Evaluation Module has completed. Check your output folder for results')

%% little subroutine to avoid repeating code
  function savePlot(plotType,classNumber,data)
    % make greyscale color map
    a = linspace(1,0,64)';
    CMap = [a,a,a];
    h = figure('NumberTitle','off','Name',[plotType ' Correlation'],'Colormap',CMap);
    set(h, 'Visible', 'off'); 
    labelsY=1:numFeatures;
    axes1=axes('YTickLabel',imgFeatureNames,'YDir','reverse','XTick',labelsY,'XAxisLocation','top','Layer','top');
    xlim([0.5 numFeatures+.5]);
    ylim([0.5 numFeatures+.5]);
    hold('all');
    image(data,'Parent',axes1,'CDataMapping','scaled');
    colorbar('peer',axes1);
    plotTitle = sprintf('%s %s Correlation DS-%s',classNames{classNumber},plotType,dataSetForPlots);
    fileTitle = sprintf('%s %s Correlation DS-%s',classNames{classNumber},plotType,dataSet);
    title(plotTitle);

    saveas(h,fullfile(AE_outputDir,fileTitle),'jpg');
    close(h);
%     disp([plotTitle,' plot has been saved']);

    %Calculate MDS for the MDS 2 component plots
    axish = gca;
    h = gcf;
    set(h, 'Visible', 'off');
    MDSProjection = cmdscale(data);
    labels = arrayfun(@num2str, 1:numFeatures, 'unif', 0);
    plot(MDSProjection(:,1),MDSProjection(:,2),'LineStyle','none');
    axis(max(max(abs(MDSProjection))) * [-1.1,1.1,-1.1,1.1]); 
    axis('square');
    text(MDSProjection(:,1),MDSProjection(:,2),labels,'HorizontalAlignment','left');
    set(axish,'XTickLabel','');
    set(axish,'YTickLabel','');
    plotTitle = sprintf('%s MDS %s Correlation DS-%s',classNames{classNumber},plotType,dataSetForPlots);
    fileTitle = sprintf('%s MDS %s Correlation DS-%s',classNames{classNumber},plotType,dataSet);
    title(plotTitle);

    saveas(h,fullfile(AE_outputDir,fileTitle),'jpg');
%     disp([plotTitle, ' plot has been saved']);
  end
end