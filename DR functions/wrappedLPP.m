function [mappedX,t_points] = wrappedLPP(trainData,testData,numDims)
    [mappedX, mappingLPP] = compute_mapping(trainData, 'LPP', numDims);
    t_points = out_of_sample(testData, mappingLPP);
