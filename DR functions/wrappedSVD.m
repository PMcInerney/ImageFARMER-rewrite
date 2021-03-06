function [mappedX,t_points] = wrappedSVD(trainData,testData,numDims)
    [~,~,V] = svd(zscore(trainData),'econ');
    mappedX = trainData * V(:,1:numDims);
    t_points= testData * V(:,1:numDims);