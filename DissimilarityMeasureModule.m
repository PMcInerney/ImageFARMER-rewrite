%    ImageFARMER-Rewrite  Dimensionality Reduction Module
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
%  DissimilarityMeasureModule()
%   Runs the Dissimilarity Measure Module of the
%   IMAGEFarmer-Rewrite CBIR building framework.
%
%   DissimilarityMeasureModule(alt_config) takes any valid configuration 
%   fields provided in the struct alt_config and substitutes them for those
%   in the function file, making it easier to adjust one or two options on
%   a run by run basis.
%

function DissimilarityMeasureModule(varargin)

    %% Configuration
    if nargin == 1
      alt_config = varargin{1};
    else
      alt_config = [];
    end


    conf = cbir_config(alt_config);
    % Global settings
    numSegments = conf.numSegments;
    numCells = numSegments*numSegments;
    numFeatures = conf.numFeatures;
    imgFeatureNames = conf.imgFeatureNames;
    dataSet = conf.dataSet;
    FDPath = conf.FDPath;
    imageClassLabelsPath = conf.imageClassLabelsPath;
    % DM specific settings
    DM_outputFolder = conf.DM_outputFolder;
    if ~exist(DM_outputFolder,'dir')
        mkdir(DM_outputFolder);
    end
    distanceFunctions = conf.DM_distanceFunctions;
    distanceNames = conf.DM_distanceNames;
    numDistances = length(distanceFunctions);
    tang_thres=conf.DM_tang_thres;           %tangent angle (in degrees) for thresholding
    hardThresholds=conf.DM_component_thresholds;
    MDS_plotColors = conf.DM_MDS_plotColors;

    plt=conf.DM_plot;                        %0 for plots , 1 for no plots
    wekaWrite=conf.DM_wekaWrite;           %0 for no weka writing, 1 for weka writing

    [FD, imageClassLabels] = loadData(FDPath,imageClassLabelsPath);
    classNames = unique(imageClassLabels);
    numImages = length(imageClassLabels);
    numClasses = length(classNames);
    disp('data loaded');
    %%%%%%%%%%%%%%%%%%%%%% End of Configuration

    %format proper string from 0-255 RGB values
    derp = num2cell(MDS_plotColors/255,2);

    formattedMDS_plotColors = cellfun(@(x)sprintf('\\color[rgb]{%f,%f,%f} ',x),derp,'unif',false); % space is important for concatenation

    classColorLabels = cell(size(imageClassLabels));
    for classCounter = 1:numClasses
        % pick out all the images for a class
        className = classNames(classCounter);
        classNameRep = repmat(className,size(imageClassLabels));
        classIndices = cellfun(@strcmp,classNameRep,imageClassLabels);
        classColorLabels(classIndices)=formattedMDS_plotColors(classCounter);
    end
    imNums = arrayfun(@num2str,1:numImages,'UniformOutput',false);
    MDS_plot_labels = cellfun(@horzcat,classColorLabels,imNums,'UniformOutput',false);

    %%Features loop
    for featureNum=1:numFeatures  %for each feature
      %% Manipulation of Feature Vectors
      % grab one feature's data from the full array (original Array is feat,image,cell)
      single_feature_data = squeeze(FD(:,:,featureNum));
      %divide each image's values by the sum of values for that image
      single_feature_data = bsxfun(@rdivide,single_feature_data,sum(single_feature_data,2));
      %avoid zeros
      single_feature_data(single_feature_data == 0) = 0.000000000000000000000001;
      skipOutput = 0; %#ok<NASGU>
      %% Loop through Measures per feature
      for distCounter=1:numDistances 
    %   for distCounter=[10 11 12]
        try
          m=squareform(pdist(single_feature_data,distanceFunctions{distCounter}));   
        catch E
          disp('error in distance calculation');
          fprintf(1,'   feature: %s\n',imgFeatureNames{featureNum});
          fprintf(1,'   dist: %s\n',distanceNames{distCounter});
          disp(E.message);
          disp('Skipping MDS and output');
          fprintf('\n');
          skipOutput = 1; %#ok<NASGU>
    %       rethrow(E);
        end
        %% MDS Calculation - If it fails output a warning and skip writing section
        skipOutput = 0;
        if ~skipOutput 
          try
            MDS_projection = cmdscale(m);
          catch E
            warning(strcat( 'error in MDS calculation\n',...
                    sprintf('   feature: %s\n',imgFeatureNames{featureNum}),...
                    sprintf('   dist: %s\n',distanceNames{distCounter}),...
                            E.message, '\n',...
                            'skipping output'));
            skipOutput = 1;
    %       rethrow(E);
          end
        end
        if ~skipOutput
            num_MDS_dims=size(MDS_projection,2);
            sumMDSVals = sum(abs(MDS_projection),1); % the sum and max are component wise, not vector-wise
            maxMDSVals = max(abs(MDS_projection),[],1);
            x = 1:num_MDS_dims;
            ExpFit = ezfit(x, sumMDSVals, 'exp'); % fit an exponential curve to the sum of the MDS values
            a = ExpFit.m(1);
            b = ExpFit.m(2); % pull out the coefficients of the exponential fit function ae^(bx)
            Points = a*exp(b*x);
            Slopes = a*b*exp(b*x); % derivative of ae^(bx) is abe^(bx)
            %% PLOTS
            if plt ~= runStatus.skip
            experimentLabel_DataDist  = horzcat(dataSet,' Distance - ',distanceNames{distCounter});
            experimentLabel_featureGrid = horzcat('-Feature-',imgFeatureNames{featureNum},'-',int2str(numSegments),'x',int2str(numSegments));
            experimentLabel_DistAndFeature = horzcat(experimentLabel_DataDist,experimentLabel_featureGrid);
            experimentLabel_PlotType = {' MDS map for '                            ,' 3D MDS map for '                                    ,' Components Plot-',...
                                        ' Sum of Components Plot-'                 ,' Scaled Image Plot '                                 ,' Grayscaled Image Plot ',...
                                        ' Exponential Curve fit for Sum Components',' Slopes of Exponential Curve fit for Sum Components '                           };
              for iplotType = 1:8
                filename = [experimentLabel_DataDist,experimentLabel_PlotType{iplotType},experimentLabel_featureGrid];
                filepath = fullfile(DM_outputFolder,filename);
                if exist(filepath,'file') && plt == runStatus.runIfMissing
                    continue
                end
                h = figure();
                set(h, 'Visible', 'off')
                switch iplotType
                    case 1
                        %% 2D MDS PLOT
                        axis(max(abs(MDS_projection(:))) * [-1.1,1.1,-1.1,1.1]); axis('square');
                        try
                            text(MDS_projection(:,1),MDS_projection(:,2),MDS_plot_labels,'HorizontalAlignment','left');
                        catch E
                            disp(size(MDS_projection));
                            disp(size(MDS_plot_labels));
                            rethrow(E);
                        end
                        %draw lines on the x and y axes
                        hx = graph2d.constantline(0, 'LineStyle','-','Color',[.7 .7 .7]);
                        changedependvar(hx,'x');
                        hy = graph2d.constantline(0,'LineStyle','-','Color',[.7 .7 .7]);
                        changedependvar(hy,'y');
                    case 2
                        %% 3D MDS PLOT
                        plot3(MDS_projection(:,1),MDS_projection(:,2),MDS_projection(:,3),'LineStyle','none');
                        text(MDS_projection(:,1),MDS_projection(:,2),MDS_projection(:,3),MDS_plot_labels,'HorizontalAlignment','left');
                        grid on;
                    case 3
                        %% Components PLOT
                        plot(maxMDSVals');
                    case 4
                        %% SUM of components PLOT
                        plot(sumMDSVals);
                    case 5
                        %% COLOR distance matrix PLOT
                        imagesc(m);
                        colorbar;
                    case 6
                        %% GRAYSCALE distance matrix PLOT
                        imagesc(m)
                        colormap(gray);
                        colorbar;
                    case 7
                        %% Exponential Curve Fitting on sum componenents PLOT
                        hold on
                        plot(x,sumMDSVals,'x')
                        plot(x,Points,'b-');
                        hold off
                    case 8
                        %% Slopes of fit curve PLOT
                        plot(Slopes)
                end
                plotTitle = horzcat(experimentLabel_DataDist,experimentLabel_PlotType{iplotType},imgFeatureNames{featureNum});
                title(char(plotTitle));
                saveas(h,filepath,'jpg');
                close(h);
              end
            end %End Plotting section
            if wekaWrite ~= runStatus.skip %% Weka part
                % take some number of the MDS values for each image and write
                % them into an arff file for classification testing
                %% Tangent based threshold
                % Determine number of components to get
                slopeAngle=180+radtodeg(atan(Slopes));
                % all slopes (and arctangents) will be 
                % negative when fitting an exponential to a generally
                % decreasing function, so add from 180 to get the desired value
                numDims_tangent = find(slopeAngle >= tang_thres,1);
                if isempty(numDims_tangent)   % if the threshold is too restrictive
                    disp('error in tangent method');
                    numDims_tangent=numCells-1;  % grab cells-1 dimensions (why?)
                end
                component_thresholds = [numDims_tangent, hardThresholds];
                % use a flag to adjust the labeling for the first output
                TangThreshFlag = 1; 
                for numComponents=component_thresholds
                  if TangThreshFlag
                    WekaLabel=strcat(dataSet,'-TangSlopeComponents-',num2str(numComponents),experimentLabel_DistAndFeature);
                    TangThreshFlag = 0;
                  else
                    WekaLabel=strcat(dataSet,'-HardThreshComponents-',num2str(numComponents),experimentLabel_DistAndFeature);
                  end
                  WekaFilename = strcat(WekaLabel,'.arff');
                  WekaFileFullPath = fullfile(DM_outputFolder,WekaFilename);
                  if exist(WekaFileFullPath,'file') && wekaWrite == runStatus.runIfMissing
                      continue
                  end
                  MDSWekaAttributeLabels = arrayfun(@num2str, 1:numComponents, 'unif', 0); % just use 1,2,... for Weka Attribute names
                  % we take the top MDS values (from the potential 63) for each image
                  try
                    dataMatrix = MDS_projection(:,1:numComponents);
                  catch E
                    disp(size(MDS_projection));
                    disp(numComponents);
                    disp(imgFeatureNames{featureNum});
                    disp(distCounter);
                    rethrow(E);
                  end
                  writeWeka(WekaFileFullPath,WekaLabel,MDSWekaAttributeLabels,classNames,dataMatrix,imageClassLabels)


                end % thresholds loop
            end % Weka Write
        end % ouput section
      end  % distances Loop
    end  %Features loop
    disp('Dissimilarity Measure Module has completed. Check your output folder for results');
end % end DM function
