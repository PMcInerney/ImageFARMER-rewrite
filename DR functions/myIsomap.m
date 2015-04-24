function [mappedX,t_points] = myIsomap(trainData,testData,numDims)
    [mappedX, mappingISO] = compute_mapping(trainData, 'Isomap', numDims);
    t_points = out_of_sample(testData, mappingISO);

	% mappedX may be smaller than trainData, because Laplacian Eigenmaps can only embed data that gives rise to a connected 
    % neighborhood graph. If the graph is not connected, only the largest connected component will be returned.
	% in this case, we use the function to map the unconnected points into the space like the test points
	if size(mappedX,1) < size(trainData,1)
        fullMappedX = zeros(1600,200);
        embeddedPointsIndex = mappingISO.conn_comp;
        missingPointsIndex = true(1,1600);
        missingPointsIndex(embeddedPointsIndex) = false;
        missingPoints = trainData(missingPointsIndex,:);
        fullMappedX(embeddedPointsIndex,:) = mappedX;
        fullMappedX(missingPointsIndex,:) = out_of_sample(missingPoints,mappingISO);
		mappedX = fullMappedX;
	end    