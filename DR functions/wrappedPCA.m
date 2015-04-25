function [mappedX,t_points] = wrappedPCA(trainData,testData,numDims)
    normedTrain = bsxfun(@minus, trainData, mean(trainData, 1));
    normedTest = bsxfun(@minus, testData, mean(testData, 1));
    COEFF = pca(trainData);
    reducedCOEFF = COEFF(:,1:numDims);
    mappedX = normedTrain*reducedCOEFF;
    t_points = normedTest*reducedCOEFF;
