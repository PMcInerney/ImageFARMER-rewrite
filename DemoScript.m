%    ImageFARMER-rewrite demo script
%    Copyright (C) 2015  Patrick McInerney
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
%    is a simple script illustrating how to make use of the
%    ImageFARMER-rewrite modules and configuration function, utilizing the
%    sample datasets
% 
addpath(genpath('.'))

for jj = -1
% for jj = [0,1,6]
    if exist('x','var')
      clear x;
    end
    x = struct;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if jj == -1
      x.dataSet = 'sample_dataset';
      x.useFile = false;
      x.datasetDir = 'sample_dataset/';
      x.outputDir = 'sample_dataset_output/';
      x.exten = 'JPG';
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
    FeatureExtractionModule(x);
    AttributeEvaluationModule(x);
    DissimilarityMeasureModule(x);
    DimensionalityReductionModule(x);
end
