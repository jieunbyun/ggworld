function lastNonZeroIndices = getLastNonZeroIndices( matrix, direction )

if nargin < 2
    direction = 1; % returns a row vector (as other matlab functions like sum)
end

switch direction
    case 1
        lastNonZeroIndices = arrayfun(@(x) find(matrix(:,x)>0,1,'last'), 1:size(matrix,2), 'UniformOutput', false);
    case 2
        lastNonZeroIndices = arrayfun(@(x) find(matrix(x,:)>0,1,'last'), 1:size(matrix,1), 'UniformOutput', false);
end

lastNonZeroIndices( cellfun( @isempty, lastNonZeroIndices ) ) = {0};
lastNonZeroIndices = cell2mat( lastNonZeroIndices );