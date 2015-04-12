totalImageCount = 1600;
numCells = 64;
numImageFeatures = 10;
FVPath = 'MSCORID_output\FV.mat';
imageClassLabelsPath = 'MSCORID_output\CL.mat';
[FV,~] = loadData(FVPath,imageClassLabelsPath);


temp = reshape(FV,totalImageCount*numCells,numImageFeatures);
maxvals = max(temp,[],1);
minvals = min(temp,[],1);
temp = bsxfun(@minus,temp,minvals);
temp = bsxfun(@rdivide,temp,maxvals-minvals);
A = reshape(temp,totalImageCount,numCells,numImageFeatures);

%FV = bsxfun(@rdivide,FE_data,sum(FE_data,2)); % each parameter is normalized to sum to one across the dataset

Histogram_Array = permute(FV,[3,1,2]);
clear maxM;
clear minM;
maxM =zeros(parameters,1);
minM =zeros(parameters,1);
%Normalize  between 0 and 1
for parm=1:parameters
    maxM(parm)=max(max(Histogram_Array(parm,:,:)));  % Max of Image Param 1
    minM(parm)=min(min(Histogram_Array(parm,:,:)));  % Max of Image Param 1
end
for nmH=1:total_im
    for tmy=1:cells
        for clse=1:parameters
            Histogram_Array(clse,nmH,tmy)=(Histogram_Array(clse,nmH,tmy) + abs(minM(clse))) / (maxM(clse)+abs(minM(clse)));
        end
    end  
end
B = permute(Histogram_Array,[2,3,1]);
C = A-B>.00001;
disp(sum(C(:)));