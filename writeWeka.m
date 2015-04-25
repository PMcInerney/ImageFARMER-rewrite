%    ImageFARMER-rewrite Weka File (ARFF) writing function
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
%   writeWeka(filename,relationName,attributeNames,classes,dataMatrix,imageClassLabels)
% 
%   A function for writing .ARFF files from Matlab data structures

function writeWeka(filename,relationName,attributeNames,classes,dataMatrix,imageClassLabels)



    fid = fopen(filename,'w');
    if fid ==-1
        error('Could not open file for weka writing');
    end
    fprintf(fid,'@relation %s\n\n',relationName);
    
    for ii = 1:length(attributeNames)
      fprintf(fid,'@attribute %s numeric\n',attributeNames{ii});
    end
    
    s = [sprintf('%s,',classes{1:end-1}), classes{end}];
    fprintf(fid,'@attribute label {%s}\n\n',s);
    
    fprintf(fid,'@data\n');
    
    for ii = 1:size(dataMatrix,1) % for each row/image
  
      % write the features of the image to the file
      dataLine = dataMatrix(ii,:);
      dataLineStrings = arrayfun(@(y)sprintf('%.10f ', y),dataLine,'UniformOutput',false);
      writableDataLine = cat(2,dataLineStrings{:});
      lineLabel = imageClassLabels{ii};
      fprintf(fid,'%s%s\n',writableDataLine,lineLabel);
    
    end
  fclose(fid);
