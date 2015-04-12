% Indexing Module (DRM) Demo
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
% MORE INFO:
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
%  Note: This module will generate the necesary files to be used with the
%  modified implementation of GIMP in C (to be used on a Linux evironment

function ClusteringModule(varargin)
    if nargin == 1
      alt_config = varargin{1};
    else
      alt_config = [];
    end
    conf = my_CBIR_config(alt_config);
    %%%%General settings      
    numClasses=conf.numClasses;
    classSize=conf.classSize;
    totalImageCount=conf.totalImageCount;
    numSegments=conf.numSegments;
    numCells=conf.numCells;                        %Grid Cell Size
    numParameters=conf.numParameters;                           %Number of Image Parameters
    FVSize=conf.FVSize;                        %Number of elements in the Feature Vector of an image
    exten=conf.exten;                        %file extension of images
    FVPath=conf.FVPath;
    imageClassLabelsPath=conf.imageClassLabelsPath;
    dataSet=conf.dataSet;
    imgFeatureNames=conf.imgFeatureNames;
    %%%%Indexing specific settings
    IM_outputDir = conf.IM_outputDir;
    IM_normalize = conf.IM_normalize;
    plt=conf.IM_plot;       %0 for plots , 1 for no plots
    % IF WE WANT ALL dimensions
    ALL_DIM=conf.IM_ALL_DIM;   %1 yes, 0 no
    % IF WE WANT DIMENSIONALLY REDUCED
    DIM_RED=conf.IM_DIM_RED;   %1 yes, 0 no
    % IF WE WANT TO RUN Dimensionality reduction in thesis context
    DIM_RED_T=1;
    %Image Parameter List 
    %% This is from the DRM Module, in the demo we hardcoded the results
    dim_to=[15,18,22,28,31,39,51,72];
    n_DM=size(dim_to,2); %Number of dimensions
    %%%%%%%%%%%%%%%%%%%%%% END OF CONFIGURATION
    
    %% Get Data from the FE files to manipulate
    [FV,imageClassLabels] = loadData(FVPath,imageClassLabelsPath);
    % FV is [image,cell,parameter]
    classNames = unique(imageClassLabels);
    %% Normalize FV 
    if IM_normalize
        temp = reshape(FV,totalImageCount*numCells,numImageFeatures);
        maxvals = max(temp,[],1);
        minvals = min(temp,[],1);
        temp = bsxfun(@minus,temp,minvals);
        temp = bsxfun(@rdivide,temp,maxvals-minvals);
        FV = reshape(temp,totalImageCount,numCells,numImageFeatures);
    end
    %% reshape FV from (image,cell,parameter) to (im,cell-param)
    FE_data = reshape(FV,totalImageCount,numCells*numImageFeatures);
    
            %% Write ALL Dimensions (original Dataset)
    if ALL_DIM

        BuildClustering();
        
    end % end all_dim section
    %% Splitting the dataset in 67 - 33% samples (equally balanced....)
    FE_data = bsxfun(@rdivide,FE_data,sum(FE_data,2)); % each parameter is normalized to sum to one across the dataset
    FE_data(FE_data==0) = 0.000000000000000000000001;  % avoid zeros

    TestIndices = boolean(zeros(1,TotalImageCount));
    TestIndices(3:3:end) = 1;
    TrainIndices = ~TestIndices;

    TrainSet = FE_data(TrainIndices,:);
    TestSet = FE_data(TestIndices,:);
    %% Actual section of dimensionality reduction
    if DIM_RED==1
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
                
                if skip ~= 1
                [n1,n2]= size(mappedX);
                tst=no_dimsEV;
                if no_dimsEV ~= n2
                    error('dimensions fucked up');
                end
                NumberComp=no_dimsEV;
                
                %WRITE TO INDEX FILES
                %Take out the bad apples  (LLE has many!)
                smx=size(mappedX,1);
                miNew=abs(min(min(mappedX)));
                maNew=max(max(mappedX));
                normby=maNew+miNew;
                for nj=1:smx
                    for nm=1:NumberComp
                        mappedX(nj,nm)=(mappedX(nj,nm)+miNew)/normby;
                    end
                end
                % normalize AGAIN?
                for nj=1:smx
                    for nm=1:NumberComp
                        if isnan(mappedX(nj,nm))
                           mappedX(nj,nm)=0; 
                        end
                        if isinf(mappedX(nj,nm))
                            mappedX(nj,nm)=0;
                        end
                    end
                end    
                clusters=round(NumberComp/2);  %Twice the dimensionality
                %Write Data
                fill1=strcat(dataSet,'-D-',num2str(NumberComp));
                fil1=strcat(pathhTOS,fill1,'-MET-',methd,'-CLU-',num2str(clusters),'.bin');
                fid = fopen(fil1, 'w');
                for tmpy=1:smx
                    fwrite(fid, mappedX(tmpy,:), 'float');
                end
                fclose(fid);
                %FIND REFERENCE POINTS
                %Clustering Section
                try
                    [IDX,C]=kmeans(mappedX,clusters);
                catch ER
                    clusters=round(clusters/2); 
                    try 
                        [IDX,C]=kmeans(mappedX,clusters);
                    catch ER2
                        clusters=round(clusters/2); 
                        try 
                            [IDX,C]=kmeans(mappedX,clusters);
                        catch ER3
                            clusters=round(clusters/2); 
                            [IDX,C]=kmeans(mappedX,clusters);
                        end
                    end
                end
                %IDX contains the cluster the points belong
                %C contains the cluster locations
                %Sequential mode of reference points
                fil2=strcat(pathhTOS,dataSet,'-D-',num2str(NumberComp),'-MET-',methd,'-CLU-',num2str(clusters),'.ref');
                fid = fopen(fil2, 'w');
                for tmpy=1:clusters
                    fprintf(fid,'%f ', C(tmpy,:));
                    fprintf(fid,'\n');
                end
                fclose(fid);     
                smt=size(t_points,1);
                miNew=abs(min(min(t_points)));
                maNew=max(max(t_points));
                normby=maNew+miNew;
                for nj=1:smt
                    for nm=1:NumberComp
                        t_points(nj,nm)=(t_points(nj,nm)+miNew)/normby;
                    end
                end
                for nj=1:smt
                    for nm=1:NumberComp
                        if isnan(t_points(nj,nm))
                           t_points(nj,nm)=0; 
                        end
                        if isinf(t_points(nj,nm))
                            t_points(nj,nm)=0;
                        end
                    end
                end        

                %Write Data
                fill1=strcat(dataSet,'-D-',num2str(NumberComp));
                fil1=strcat(pathhTOS,fill1,'-MET-',methd,'-CLU-',num2str(clusters),'.quer');
                fid = fopen(fil1, 'w');
                for tmpy=1:smt
                    fwrite(fid, t_points(tmpy,:), 'float');
                end
                fclose(fid);    

                no_dimsEV=tst;
                skip=0;
                end
            end %Reduction Methods loop
        end % Dimensions Loop
    end %Dim Reduction execute or not?
    %%Actual section of dimensionality reduction
    TO DO: add code to cover the 'thesis' style of 'indexing'
    (use whole data set to run DR)
    msg='Indexing Module Demo has been completed. Check your output folder for results' 
 
    function BuildClustering()
        clusters=round(FVSize/2);  %Twice the dimensionality
        indexTitle = sprintf('%s_D=%d_CLU=%d',dataSet,FVSize,clusters);
        fullPath=fullfile(IM_outputDir,[indexTitle,'.bin']);
% writing full data
%         fid = fopen(fil1, 'w');
%         for tmpy=1:totalImageCount
%             fwrite(fid, FE_data(tmpy,:), 'float');
%         end
        fclose(fid);
        %FIND REFERENCE POINTS
        %Clustering Section
        try
            [IDX,C]=kmeans(FE_data,clusters);
        catch ER
            clusters=round(clusters/2); 
            try 
                [IDX,C]=kmeans(FE_data,clusters);
            catch ER2
                clusters=round(clusters/2); 
                try 
                    [IDX,C]=kmeans(FE_data,clusters);
                catch ER3
                    clusters=round(clusters/2); 
                    [IDX,C]=kmeans(FE_data,clusters);
                end
            end
        end
        %IDX contains the cluster the points belong
        %C contains the cluster locations
        fullPath=fullfile(IM_outputDir,[indexTitle,'.txt']);
        fid = fopen(fullPath, 'w');
        for tmpy=1:clusters
            fprintf(fid,'%f ', C(tmpy,:));
            fprintf(fid,'\n');
        end
        fclose(fid);
    end
end %end function
