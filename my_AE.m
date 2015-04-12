%% Attribute Evaluation Module (AEM) - DEMO
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
%  Stand-alone script to ilustrate the usage of the Attribute Evaluation
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

function my_AE(varargin)

    if nargin == 1
      alt_config = varargin{1};
    else
      alt_config = [];
    end

    %%%%% Main Variables
    config_ops = my_CBIR_config(alt_config);
    numClasses = config_ops.numClasses;
    classSize = config_ops.classSize;
    numParameters = config_ops.numParameters;
    dataSet = config_ops.dataSet;
    FVPath = config_ops.FVPath;
    imageClassLabelsPath = config_ops.imageClassLabelsPath;
    %Save to path
    AE_outputDir = config_ops.AE_outputDir;
    if ~exist(AE_outputDir,'dir')
        mkdir(AE_outputDir);
    end
    imgParam = config_ops.imgParameters;
    %^used for plotting axis labels

    %%%%%%%%End of variable Configuration%%%%%%%
    % the expected histogram array in Juan's code is 
    % 10        1600          64
    % The FV is 
    % 1600    64    10


    %% Actual Code
    [FV, imageClassLabels] = loadData(FVPath,imageClassLabelsPath);
    classNames = unique(imageClassLabels);
tic
    %% Calculate average between-image correlation
    range1 = 1;
    range2 = classSize;  %class size
    averageCorrelation = zeros(numClasses,numParameters,1); % the average correlation among values of a single parameter for a single class
    for classCounter = 1:numClasses
        for param=1:numParameters %for each parameter
            imageCorrelations = pdist(FV(range1:range2,:,param),'correlation');
            averageCorrelation(classCounter,param) = 2*sum(imageCorrelations)/classSize^2; % calculate mean distance of non-squareform distance matrix
        end
        range1 = range1 + classSize; % shift class markers
        range2 = range2 + classSize;
    end

    %% Make and save the intra class plots
    for classCounter = 1:numClasses
        X = averageCorrelation(classCounter,:);
        intraCorrMat = squareform(pdist(X(:)));
        intraCorrDistMat = 1-intraCorrMat;
        savePlot('IntraClass',classCounter,intraCorrDistMat)
    end
    %% Make and save the inter class plots
    derp = zeros(numClasses,numParameters,numClasses);
    for param = 1:numParameters
        X = averageCorrelation(:,param);
        derp(:,param,:) = squareform(pdist(X(:)));
    end
    classCompare = mean(derp,3);
    for classCounter = 1:numClasses
        X = classCompare(classCounter,:);
        interCorrMat = squareform(pdist(X(:)));
        interCorrDistMat = 1-interCorrMat;
        savePlot('InterClass',classCounter,interCorrDistMat)
    end
%% and we're done
    disp('Attribute Evaluation Demo has been completed. Check your output folder for results')

%% little subroutine to avoid repeating code
  function savePlot(plotType,classNumber,data)
    % make greyscale color map
    a = linspace(1,0,64)';
    CMap = [a,a,a];
    h = figure('NumberTitle','off','Name',[plotType ' Correlation'],'Colormap',CMap);
    set(gcf, 'Visible', 'off'); 
    labelsY=1:numParameters;
    axes1=axes('YTickLabel',imgParam,'YDir','reverse','XTick',labelsY,'XAxisLocation','top','Layer','top');
    xlim([0.5 numParameters+.5]);
    ylim([0.5 numParameters+.5]);
    hold('all');
    image(data,'Parent',axes1,'CDataMapping','scaled');
    colorbar('peer',axes1);
    plotTitle = sprintf('%s %s Correlation DS-%s',classNames{classNumber},plotType,dataSet);
    title(plotTitle);

    saveas(h,fullfile(AE_outputDir,plotTitle),'jpg');
    close(h);
%     disp([plotTitle,' plot has been saved']);

    %Calculate MDS for the MDS 2 component plots
    h = gca;
    MDSProjection = cmdscale(data);
    labels = arrayfun(@num2str, 1:numParameters, 'unif', 0);
    set(h, 'Visible', 'off');
    plot(MDSProjection(:,1),MDSProjection(:,2),'LineStyle','none');
    axis(max(max(abs(MDSProjection))) * [-1.1,1.1,-1.1,1.1]); 
    axis('square');
    text(MDSProjection(:,1),MDSProjection(:,2),labels,'HorizontalAlignment','left');
    set(h,'XTickLabel','');
    set(h,'YTickLabel','');
    plotTitle = sprintf('%s MDS %s Correlation DS-%s',classNames{classNumber},plotType,dataSet);
    title(plotTitle);

    saveas(h,fullfile(AE_outputDir,plotTitle),'jpg');
%     disp([plotTitle, ' plot has been saved']);
  end
 toc
end