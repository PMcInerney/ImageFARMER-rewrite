% run the KernelPCA mapping from the DR Toolbox
function [mappedX,t_points] = wrappedKPCA(trainData,testData,numDims)
    [mappedX, mappingKPCA] = compute_mapping(trainData, 'KernelPCA', numDims);
    t_points = out_of_sample(testData, mappingKPCA);
