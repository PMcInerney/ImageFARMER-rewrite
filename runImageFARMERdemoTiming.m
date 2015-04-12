%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code runs FE (construction of parameter data)
% on all datasets, so we can run
% the WEKA parameter evaluation code on it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('.'))

for jj = -1
    if exist('x','var')
      clear x;
    end
    x = struct;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if jj == -1
      x.dataSet = 'MSCORID_subset';
      x.useFile = false;
      x.datasetDir = '../datasets/MSCORID_subset/';
      x.outputDir = 'MSCORID_subset_output/';
      x.exten = 'JPG';
      x.classSize = 20;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if jj == 0
      x.dataSet = 'MSCORID';
      x.useFile = false;
      x.datasetDir = '../datasets/MSCORID/';
      x.outputDir = 'MSCORID_output/';
      x.exten = 'JPG';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if jj == 1
      x.dataSet = 'CLEFMED2007';
      x.useFile = false;
      x.datasetDir = '../datasets/ImageCLEFmed2007/';
      x.outputDir = '/data/home/pmcinerney/CFM2007_Out';
      x.exten = 'png';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if jj == 2
      x.dataSet = 'CLEFMED2005';
      x.useFile = false;
      x.datasetDir = 'ImageCLEFmed05/';
      x.outputDir = '/data/home/pmcinerney/CFM2005_Out';
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
      x.datasetDir = '/data/home/pmcinerney/TRACE/';
      x.imageListFile = '';
      x.outputDir = '/data/home/pmcinerney/TRACE_Out';
      x.exten = 'tif';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%run modules
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  my_FE(x);
  tic
  profile on
   my_DR(x);
  toc
  profile off
end
