function [tNewSource, tNewDestination, tNewWeights] = sun_computeW(options, superpixels, flow, colours, labels, foregroundMasks )

folder = fullfile( options.outfolder, 'processing' );
if( ~exist( folder, 'dir' ) )
    mkdir( folder );
end
 filename = fullfile( folder, sprintf( 'sun_W.mat' ) );






[ tSource, tDestination, tConnections ] = ...  %  tConnections: 比率，% t的相似性（交集/warp（上一个块）且正数坐标）
        getTemporalConnections( flow, superpixels, labels );
    
tSource = tSource + 1;  tDestination =  tDestination + 1;

% 构建超边关系
uniqueDestination = unique( tDestination ); 
ternaryElements = [];
for i = 1:length( uniqueDestination )
    tempIndex = find( tDestination == uniqueDestination(i) );
    tempIdx = find( tSource == uniqueDestination(i) );
    
    tempBox = zeros(length(tempIdx)*length(tempIndex), 3, 'uint64');

    [X, Y] = meshgrid( tSource(tempIndex), tDestination(tempIdx) );
    tempBox(:, 1) = reshape(X, [], 1); tempBox(:, 2) = uniqueDestination(i);
    tempBox(:, 3) = reshape(Y, [], 1);

    ternaryElements = [ternaryElements; tempBox];
end

ternarySource = ternaryElements(:, 1); ternaryBridge = ternaryElements(:, 2); ternaryDestination = ternaryElements(:, 3);
[totalColours(:, :, 1), totalColours(:, :, 2), totalColours(:, :, 3)] = deal( colours(ternarySource, :),  colours(ternaryBridge , :),  colours(ternaryDestination , :));
averageColours = mean(totalColours, 3);

tColourDistance = sum([( colours( ternarySource, : ) - averageColours( :, : ) ) .^ 2, ...
                    ( colours(  ternaryBridge, : ) - averageColours( :, : ) ) .^ 2, ...
                    ( colours( ternaryDestination, : ) - averageColours( :, : ) ) .^ 2], 2)/3;

        
% 构建相似性
tSource = uint64(tSource); tDestination = uint64(tDestination);
% tVector = (tDestination - 1)*labels + tSource; 
tVector = sub2ind([labels, labels], tSource, tDestination);


tVector12 = sub2ind([labels, labels], ternarySource, ternaryBridge);
% tVector12 = ( ternaryBridge - 1)*labels + ternarySource; 
[uniqueVector12, anyvalues, index12] = unique(tVector12);
[anyvalues, anyvalues, index] = intersect(uniqueVector12, tVector);
uniqueVector12Connections = tConnections( index );
Vector12Connections = uniqueVector12Connections( index12 );

% tVector23 = ( ternaryDestination - 1)*labels + ternaryBridge; 
tVector23 = sub2ind([labels, labels], ternaryBridge, ternaryDestination);
[uniqueVector23, anyvalues, index23] = unique(tVector23);
[anyvalues, anyvalues, index] = intersect(uniqueVector23, tVector);
uniqueVector23Connections = tConnections( index );
Vector23Connections = uniqueVector23Connections( index23 );

% Vector13Connections = []; 
% [height width, anyvalues] = size(flow{1});
% for i = 1:length(ternarySource)
%     sourceFrameId = nodeFrameId(ternarySource(i)); destinationFrameId = nodeFrameId(ternaryDestination(i));
%     u1 = flow{sourceFrameId}(:,:,2); v1 = flow{sourceFrameId}(:,:,1);
%     u1 = reshape(u1,[], 1); v1 = reshape(v1,[], 1);
%     
%     index1 = find( superpixels{sourceFrameId} == ternarySource(i) );
%     newIndex1 = index1 + double(u1(index1))*height + double(v1(index1));
%     
%     u2 = flow{sourceFrameId+1}(:,:,2); v2 = flow{sourceFrameId+1}(:,:,1);
%     u2 = reshape(u2,[], 1); v2 = reshape(v2,[], 1);
%      newIndex1 = newIndex1(newIndex1 > 0 & newIndex1 <=  height *width);
% 
%     
%     newIndex2 = newIndex1 + double(u2(newIndex1))*height + double(v2(newIndex1));
%     newIndex2 = newIndex2(newIndex2 > 0 & newIndex2 <=  height *width);
%     
%     if isempty(newIndex2)
%         Vector13Connections = [Vector13Connections; 0];
%         continue;
%     end
%     
%     index3 = find(superpixels{destinationFrameId} == ternaryDestination(i));
%     Vector13Connections = [Vector13Connections; length(intersect(newIndex2, index3))/length(newIndex2)]; 
% end

% fai = Vector12Connections .* Vector23Connections .* Vector13Connections;
%  tBeta = 0.5 / mean( tColourDistance .* (fai).^(1/3) );

fai = (Vector12Connections  + Vector23Connections)/2 ;  % 超边关系的相似性

denominator = tColourDistance .* fai;
 tBeta = 1/ mean( denominator(foregroundMasks(ternarySource) | foregroundMasks(ternaryBridge) | foregroundMasks(ternaryDestination)) );

 tWeights = fai .* exp( -tBeta * tColourDistance );
% 模板外的节点，赋予一个极大的值 
tWeights(~( foregroundMasks(ternarySource) | foregroundMasks(ternaryBridge) | foregroundMasks(ternaryDestination) )) = inf;  % 30

 
 
 
tBinaryElements = zeros( length(tWeights) * 3, 2, 'uint64');
tBinaryWeights = zeros( length(tWeights) * 3, 1, 'single');

tBinaryElements(1:3:end, :) = [ternarySource, ternaryBridge]; tBinaryElements(2:3:end, :) = [ternaryBridge, ternaryDestination];
tBinaryElements(3:3:end, :) = [ternarySource, ternaryDestination];
tBinaryWeights(1:3:end, :) = tWeights ; tBinaryWeights(2:3:end, :) = tWeights; tBinaryWeights(3:3:end, :) = tWeights;

% tVectorElements = (tBinaryElements(:, 2) - 1)*labels + tBinaryElements(:, 1); 
tVectorElementsTotal  = sub2ind([labels, labels], tBinaryElements(:, 1), tBinaryElements(:, 2));

% 筛选
% tVector = (tDestination - 1)*labels + tSource; 
tVector = sub2ind([labels, labels], tSource, tDestination);
tVector = uint64(tVector);
tVectorElements = tVectorElementsTotal(ismember(tVectorElementsTotal, tVector));
tBinaryWeights = tBinaryWeights(ismember(tVectorElementsTotal, tVector));

% 'descend'   求最大值
[tBinaryWeights, index] = sort(tBinaryWeights, 'descend'); tVectorElements = tVectorElements( index );  
[tVectorElements, index2] = sort(tVectorElements); tBinaryWeights = tBinaryWeights( index2 );  
[tVectorElements, minValuesIndex] = unique( tVectorElements ); tBinaryWeights = tBinaryWeights( minValuesIndex );

% % 平均
% [tVectorElements, index] = sort(tVectorElements );
% 
% [tBinaryElem(:, 1), tBinaryElem(:, 2)] = ind2sub([labels, labels], tVectorElements);
% % tBinaryElements = tBinaryElements(index, :); 
% tBinaryWeights = tBinaryWeights( index );
% tBinaryWeights(tBinaryWeights==0) = eps;
% sparseFormat = sparse(double(tBinaryElem(:, 1)), double(tBinaryElem(:, 2)), double(tBinaryWeights));
% [tNewSource, tNewDestination, sumWeights] = find( sparseFormat );
% [anyvalues, relativeLocations] = unique(tVectorElements);
% numOfweights = [diff(relativeLocations); length(tVectorElements) - relativeLocations(end)+1];
% tBinaryWeights = sumWeights ./ numOfweights;

% tNewWeights = single(tBinaryWeights);
% tNewDestination = uint32(tNewDestination) - 1;  % c语言下标从0开始
% tNewSource =  uint32(tNewSource)-1;



[tNewSource, tNewDestination]  = ind2sub([labels, labels], tVectorElements);
% % tNewDestination = fix( double(tVectorElements)/labels ) + 1;
% % % tNewSource = tVectorElements - (tNewDestination-1) *labels;
% % tNewSource = mod(double(tVectorElements), labels);
% 
tNewWeights = single(tBinaryWeights);
tNewDestination = uint32(tNewDestination) - 1;  % c语言下标从0开始
tNewSource =  uint32(tNewSource)-1;
    
    save( filename, 'tNewSource', 'tNewDestination', 'tNewWeights');
    

