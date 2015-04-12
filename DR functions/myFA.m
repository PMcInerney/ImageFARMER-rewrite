function [mappedX,t_points] = myFA(trainData,testData,numDims)
    [mappedX, mappingFA] = compute_mapping(trainData, 'FactorAnalysis', numDims);
    t_points = out_of_sample(testData, mappingFA);
