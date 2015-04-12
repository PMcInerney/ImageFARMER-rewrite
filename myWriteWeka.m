function myWriteWeka(filename,relationName,featureNames,classes,dataMatrix,imageClassLabels)
%matlab2weka('derp',featureNames,tempData)
%   try
    fid = fopen(filename,'w');
     
    fprintf(fid,'@relation %s\n\n',relationName);
    
    for ii = 1:length(featureNames)
      fprintf(fid,'@attribute %s numeric\n',featureNames{ii});
    end
    
    s = [sprintf('%s,',classes{1:end-1}), classes{end}];
    fprintf(fid,'@attribute label {%s}\n\n',s);
    
    fprintf(fid,'@data\n');
    
    for ii = 1:size(dataMatrix,1) % for each row/image
  
      %Some progress updating
%       if mod(ii,100) == 0
%         fprintf('%d/%d\n',ii,size(dataMatrix,1));
%       end

      % write the parameters of the image to the file
      dataLine = dataMatrix(ii,:);
      dataLineStrings = arrayfun(@(y)sprintf('%.10f ', y),dataLine,'UniformOutput',false);
      writableDataLine = cat(2,dataLineStrings{:});
      lineLabel = imageClassLabels{ii};
      fprintf(fid,'%s%s\n',writableDataLine,lineLabel);
    
    end
  fclose(fid);
%   catch exception
%     if exist(filename, 'file')==2
%       delete(filename);
%     end
%     rethrow(exception);
%   end
%   
