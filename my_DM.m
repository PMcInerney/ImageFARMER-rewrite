%% Dissimilarity Measures Module (DMM) Demo
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
%
%  Forced Outputs: Saved variables for the KLD, JSD, CHI2 Measures
%  Configurable Outputs: 2D/3D MDS plots, Curve Fitting Plots, Components
%  Plots, Weka files for Hard-threshold and tanget threshold experiments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%modified by Patrick McInerney
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function my_DM(varargin)
if nargin == 1
  alt_config = varargin{1};
else
  alt_config = [];
end
%%%%% Main Variables
conf = my_CBIR_config(alt_config);



%%%% Global settings
classSize = conf.classSize;
total_im = conf.totalImageCount;
segments = conf.numSegments;
cells = conf.numCells;
numParameters = conf.numParameters;
paramNames = conf.imgParameters;
dataSet = conf.dataSet;
FVPath = conf.FVPath;
imageClassLabelsPath = conf.imageClassLabelsPath;
DM_outputFolder = config_ops.DM_outputDir;
if ~exist(DM_outputFolder,'dir')
    mkdir(DM_outputFolder);
end
imgParam = conf.imgParameters;
%%%%DM specific settings
distanceFunctions = conf.DM_distanceFunctions;
distanceNames = conf.DM_distanceNames;
numDistances=conf.DM_numDistances;             %Number of different distances
tang_thres=conf.DM_tang_thres;           %tangent angle (in degrees) for thresholding comp$
hardThresholds=conf.DM_component_thresholds;

%hardcoded for 8 classes
%space at the end of each entry is important
classColors = {'\color{red} ','\color{green} ','\color{blue} ','\color{yellow} ','\color{magenta} ','\color{gray} ','\color{orange} ','\color{black} '};
classColorLabels = repmat(classColors,classSize,1);
classColorLabels = reshape(classColorLabels,1,total_im);
imNums = arrayfun(@num2str,1:total_im,'UniformOutput',false);
MDS_plot_labels = cellfun(@horzcat,classColorLabels,imNums,'UniformOutput',false);

%If there is need to re-run a section  (DEVELOPER MODE)  Default all should be 1
plt=conf.DM_plot;                        %0 for plots , 1 for no plots
weka_write=conf.DM_weka_write;           %0 for no weka writing, 1 for weka writing
%%%%%%%%%%%%%%%%%%%%%% END OF GLOBAL VARIABLES

%% Get Data from the FE files to manipulate

%%FV is (image, parameter, cell)
[FV, imageClassLabels] = loadData(FVPath,imageClassLabelsPath);
classNames = unique(imageClassLabels);
disp('data loaded');

%%Parameters loop
for curr_param=1:numParameters  %for each parameter
% for curr_param=1  %for each parameter
  %% Manipulation of Feature Vectors
  % grab one parameter's data from the full array (original Array is param,image,cell)
  single_parameter_data = squeeze(FV(:,:,curr_param));
  %divide each image's values by the sum of values for that image
  single_parameter_data = bsxfun(@rdivide,single_parameter_data,sum(single_parameter_data,2));
  %avoid zeros
  single_parameter_data(single_parameter_data == 0) = 0.000000000000000000000001;
  skipOutput = 0; %#ok<NASGU>
  %% Loop through Measures per parameter
  for distCounter=1:numDistances 
%   for distCounter=[10 11 12]
    try
      m=squareform(pdist(single_parameter_data,distanceFunctions{distCounter}));   
    catch E
      disp('error in distance calculation');
      fprintf(1,'   param: %s\n',paramNames{curr_param});
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
        disp('error in MDS calculation');
        fprintf(1,'   param: %s\n',paramNames{curr_param});
        fprintf(1,'   dist: %s\n',distanceNames{distCounter});
        disp(E.message);
        disp('skipping output');
        fprintf('\n');
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
        if ~plt
            %do nothing
        else
        experimentLabel_DataDist  = horzcat(dataSet,' Distance - ',distanceNames{distCounter});
        experimentLabel_ParamGrid = horzcat('-Feature-',imgParam{curr_param},'-',int2str(segments),'x',int2str(segments));
        experimentLabel_DistAndParam = horzcat(experimentLabel_DataDist,experimentLabel_ParamGrid);
        experimentLabel_PlotType = {' MDS map for '                            ,' 3D MDS map for '                                    ,' Components Plot-',...
                                    ' Sum of Components Plot-'                 ,' Scaled Image Plot '                                 ,' Grayscaled Image Plot ',...
                                    ' Exponential Curve fit for Sum Components',' Slopes of Exponential Curve fit for Sum Components '                           };
          for iplotType = 1:8
            h = figure();
            set(h, 'Visible', 'off')
            if iplotType == 1
              %% 2D MDS PLOT
              plot(MDS_projection(:,1),MDS_projection(:,2),'LineStyle','none');
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
            elseif iplotType == 2
              %% 3D MDS PLOT
              plot3(MDS_projection(:,1),MDS_projection(:,2),MDS_projection(:,3),'LineStyle','none');
              text(MDS_projection(:,1),MDS_projection(:,2),MDS_projection(:,3),MDS_plot_labels,'HorizontalAlignment','left');
              grid on;
            elseif iplotType == 3
              %% Components PLOT
              plot(maxMDSVals');
            elseif iplotType == 4
              %% SUM of components PLOT
              plot(sumMDSVals);
            elseif iplotType == 5
              %% COLOR distance matrix PLOT
              imagesc(m);
              colorbar;
            elseif iplotType == 6 
              %% GRAYSCALE distance matrix PLOT
              imagesc(m)
              colormap(gray);
              colorbar;
            elseif iplotType == 7
              %% Exponential Curve Fitting on sum componenents PLOT
              hold on
              plot(x,sumMDSVals,'x')
              plot(x,Points,'b-');
              hold off
            elseif iplotType == 8
              %% Slopes of fit curve PLOT
              plot(Slopes)
            end
            filename = [experimentLabel_DataDist,experimentLabel_PlotType{iplotType},experimentLabel_ParamGrid];
            filepath = fullfile(DM_outputFolder,filename);
            plotTitle = horzcat(experimentLabel_DataDist,experimentLabel_PlotType{iplotType},imgParam{curr_param});
            title(char(plotTitle));
            saveas(h,filepath,'jpg');
            close(h);
          end
        end %End Plotting section
        if weka_write %% Weka part
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
                numDims_tangent=cells-1;  % grab cells-1 dimensions (why?)
            end
            component_thresholds = [numDims_tangent, hardThresholds];
            % use a flag to adjust the labeling for the first output
            TangThreshFlag = 1; 
            for numComponents=component_thresholds
              if TangThreshFlag
                WekaLabel=strcat(dataSet,'-TangSlopeComponents-',num2str(numComponents),experimentLabel_DistAndParam);
                TangThreshFlag = 0;
              else
                WekaLabel=strcat(dataSet,'-HardThreshComponents-',num2str(numComponents),experimentLabel_DistAndParam);
              end
              WekaFilename = strcat(WekaLabel,'.arff');
              WekaFileFullPath = fullfile(DM_outputFolder,WekaFilename);
              MDSParamWekaLabels = arrayfun(@num2str, 1:numComponents, 'unif', 0); % just use 1,2,... for parameter names
              % we take the top MDS values (from the potential 63) for each image
              try
                dataMatrix = MDS_projection(:,1:numComponents);
              catch E
                disp(size(MDS_projection));
                disp(numComponents);
                disp(imgParam{curr_param});
                disp(distCounter);
    %             X = MDS_projection
    %             save(
                rethrow(E);
              end
              myWriteWeka(WekaFileFullPath,WekaLabel,MDSParamWekaLabels,classNames,dataMatrix,imageClassLabels)

            
            end % thresholds loop
        end % Weka Write
    end % ouput section
  end  % distances Loop
end  %Parameters loop
% function makeAGodDamnPlot()
%     h = figure();
%     set(h, 'Visible', 'off');
%     plotTitle = [experimentLabel_DataDist,experimentLabel_PlotType{iplotType},experimentLabel_ParamGrid];
%     
%     filepath = fullfile(DM_outputFolder,plotTitle);
%     title(char(plotTitle));
%     saveas(h,filepath,'jpg');
%     close(h);
% end % plotting function
disp('Dissimilarity Measure Module Demo has been completed. Check your output folder for results');
%end% end DM function
