%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code runs FE (construction of parameter data)
% on all datasets, so we can run
% the WEKA parameter evaluation code on it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('.'))

% for jj = -1
for jj = [0,1,6]
    if exist('x','var')
      clear x;
    end
    x = struct;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if jj == -1
      x.dataSet = 'MSRCORID_subset';
      x.useFile = false;
      x.datasetDir = '../datasets/MSRCORID_subset/';
      x.outputDir = 'MSRCORID_subset_output/';
      x.exten = 'JPG';
      x.FE_writeParameterImages = runStatus.overwrite;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if jj == 0
      x.dataSet = 'MSRCORID';
      x.useFile = false;
      x.datasetDir = '../datasets/MSRCORID/';
      x.outputDir = 'MSRCORID_output/';
      x.exten = 'JPG';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if jj == 1
      x.dataSet = 'CLEFMED2007';
      x.useFile = false;
      x.datasetDir = '../datasets/ImageCLEFmed2007/';
      x.outputDir = 'CFM2007_Out/';
      x.exten = 'png';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if jj == 2
      x.dataSet = 'CLEFMED2005';
      x.useFile = false;
      x.datasetDir = 'ImageCLEFmed05/';
      x.outputDir = 'CFM2005_Out/';
      x.exten = 'png';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if jj == 3
      x.dataSet = 'PASCAL2008';
      x.useFile = true;
      x.datasetDir = ''; % datasetDir is empty because the imageListFile is used to determine where the images are
      x.imageListFile = 'PASCAL08_image_list.txt';
      x.outputDir = '/data/home/pmcinerney/PASCAL2008_Out';
      x.exten = 'png';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if jj == 4
      x.dataSet = 'PASCAL2006';
      x.useFile = true;
      x.datasetDir = ''; % datasetDir is empty because the imageListFile is used to determine where the images are
      x.imageListFile = 'PASCAL06_image_list.txt';
      x.outputDir = '/data/home/pmcinerney/PASCAL2006_Out';
      x.exten = 'png';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if jj == 5
      x.dataSet = 'INDECS';
      x.useFile = false;
      x.datasetDir = '/data/home/pmcinerney/INDECS/';
      x.imageListFile = '';
      x.outputDir = '/data/home/pmcinerney/INDECS_Out';
      x.exten = 'tif';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if jj == 6
      x.dataSet = 'TRACE';
      x.useFile = false;
      x.datasetDir = '../datasets/TRACE/';
      x.imageListFile = '';
      x.outputDir = 'TRACE_Out';
      x.exten = 'tif';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%run modules
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
profile on;
    FeatureExtractionModule(x);
profsave(profile('info'),[x.dataSet,'_FE profile']);
profile clear;
     AttributeEvaluationModule(x);
profsave(profile('info'),[x.dataSet,'_AE profile']);
profile clear;
   DissimilarityMeasureModule(x);
profsave(profile('info'),[x.dataSet,'_DM profile']);
profile clear;
   DimensionalityReductionModule(x);
profsave(profile('info'),[x.dataSet,'_DR profile']);
profile off
end
