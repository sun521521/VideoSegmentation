function objectPossibility = sun_objectPossibility(options,bounds, oldLabels,  potentialMatrix, superpixels, pairPotentials, vNumbers,params, data, i)

folder = fullfile( options.outfolder, 'objectPossibility' );
if( ~exist( folder, 'dir' ) )
    mkdir( folder );
end
 filename = fullfile( folder, sprintf( 'objectPossibility_%d.mat', i ) );




% sampleRate = 1; 
objectPossibility = ones( bounds(end)-1, 2 );
coarseSeeds1 = find(oldLabels == 1);   coarseSeeds2 = find(oldLabels == 0); 

% coarseSeeds1 = []; coarseSeeds2 = [];
% for frame = 1:length( superpixels )-1
%     perFrameNodes = foregroundNodes(foregroundNodes>=bounds(frame) & foregroundNodes<bounds(frame+1)-1);
%     nodeNumbers = length( perFrameNodes );
%     sampleLocations = randperm( nodeNumbers, floor(nodeNumbers*sampleRate) );
%     coarseSeeds1 = [coarseSeeds1, perFrameNodes( sampleLocations )'];
% end
% 
% for frame = 1:length( superpixels )-1
%     perFrameNodes = backgroundNodes(backgroundNodes>=bounds(frame) & backgroundNodes<bounds(frame+1)-1);
%     nodeNumbers = length( perFrameNodes );
%     sampleLocations = randperm( nodeNumbers, floor(nodeNumbers*sampleRate) );
%     coarseSeeds2 = [coarseSeeds2, perFrameNodes( sampleLocations )'];
% end



appearance = mapBelief( potentialMatrix.appearance ); location = mapBelief( potentialMatrix.location );  LA = mapBelief(  potentialMatrix.LA  );
appearance1 = appearance( coarseSeeds1 ); location1 = location( coarseSeeds1 );  LA1 = LA( coarseSeeds1 );
appearance2 = appearance( coarseSeeds2 ); location2 = location( coarseSeeds2 );  LA2 = LA( coarseSeeds2 );

% masks = (appearance2./maxmax(appearance2) > 0.9  &  LA2 ./maxmax( LA2 ) > 0.85)...
%              |  ( location2./maxmax(location2) > 0.85 &  LA2 ./maxmax( LA2 ) > 0.85 );
  

masks1 = (appearance1./maxmax(appearance1) > 0.45  &  LA1 ./maxmax( LA1 ) > 0.55) | (location1./maxmax(location1) > 0.85 &  LA1 ./maxmax( LA1 ) > 0.6);
% masks2 = appearance2./maxmax(appearance2) < 0.88  &  LA2 ./maxmax( LA2 ) < 0.88 & location2./maxmax(location2) < 0.88;

seeds1 = coarseSeeds1( masks1 ); 
% seeds2 = coarseSeeds2( masks2 );
% seeds1 = seeds1(1:3:end); seeds2 = seeds2(1:3:end);
seeds1 = seeds1(1:4:end);



if isempty(seeds1) 
     return
end
% frames = length( unaryPotential );
% for frame = 1:frames
%     
%   maxPossibility = maxmax(unaryPotential{frame});
%    threshold1  = maxPossibility * beta1;  threshold2  = maxPossibility * beta2;
%    
%     superFrame = superpixels{frame};
%     seed = superFrame(unaryPotential{frame} >= threshold1 & unaryPotential{frame} <= threshold2);
%     seed  = reshape(unique(seed), 1, []);
%      seeds = [seeds, seed];
% end



probabilities1 = random_walker(pairPotentials, seeds1, [1:length(seeds1)], vNumbers);
% probabilities2 = random_walker(pairPotentials, seeds2, [1:length(seeds2)], vNumbers);


% probabilities = mean(probabilities, 2);
% probabilities = probabilities(:, 1);
probabilities1 = max(probabilities1,[], 2); 
probabilities1(probabilities1 > 0.8) = probabilities1(probabilities1 > 0.8)*0.8;
% probabilities2 = max(probabilities2,[], 2);

[ result, probabilities12 ] = accumulateProbabilities( params, data, probabilities1, bounds );  % 修正
% probabilities12 = probabilities1;

clear probabilities1 probabilities2;

probabilities12 = probabilities12./(max(probabilities12));
% probabilities12( probabilities12 > 0.95 ) = 0.999; 

probabilities22 = 1 - probabilities12;


objectPossibility( 1:length(probabilities12), :) = [probabilities12, probabilities22]; % test时要归一化

clear probabilities12 probabilities22;
save( filename, 'objectPossibility');


