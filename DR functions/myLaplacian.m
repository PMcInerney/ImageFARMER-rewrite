% run the Laplacian Eigenmaps-based mapping from the DR Toolbox
function [mappedX,t_points] = myLaplacian(trainData,testData,numDims)
    [mappedX, mapping] = compute_mapping(trainData, 'Laplacian', numDims);
	% Laplacian eigenmap reductions are base on conn
    t_points = out_of_sample(testData, mapping); % these points are mapped via Nystrom approximation

	% mappedX may be smaller than trainData, because Laplacian Eigenmaps can only embed data that gives rise to a connected 
    % neighborhood graph. If the graph is not connected, only the largest connected component will be returned.
	% in this case, we use the function to map the unconnected points into the space like the test points
	if size(mappedX,1) < size(trainData,1)
        fullMappedX = zeros(1600,200);
        embeddedPointsIndex = mapping.conn_comp;
        missingPointsIndex = true(1,1600);
        missingPointsIndex(embeddedPointsIndex) = false;
        missingPoints = trainData(missingPointsIndex,:);
        fullMappedX(embeddedPointsIndex,:) = mappedX;
        fullMappedX(missingPointsIndex,:) = out_of_sample(missingPoints,mapping);
		mappedX = fullMappedX;
	end