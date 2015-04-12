function [mappedX,t_points] = myPCA(trainData,testData,numDims)
    [mappedX, mappingPCA] = compute_mapping(trainData, 'PCA', numDims);
    t_points = out_of_sample(testData, mappingPCA);
