function test_objectPossibility(objectPossibility,superpixels)
% % test_objectPossibility(data.unaryPotential, superpixels, pairPotentials)
% %  pairPotentials.value=pairPotentials.value( 180751:end)
% 
% normFactor = 0.75;
% frames = length( unaryPotential );
% seeds = [];   
%  beta1 = 0.90;  beta2 = 0.95;  %  beta1 = 0.76;  beta2 = 0.88;
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
% 
% probabilities = random_walker(pairPotentials, seeds, [1:length(seeds)]);
% 
% % probabilities = mean(probabilities, 2);
% % probabilities = probabilities(:, 1);
% probabilities = max(probabilities,[], 2);
% 
% probabilities  = probabilities./(max(probabilities(probabilities ~= 1)) * normFactor);
% probabilities(probabilities > 1) = 1;
% 


a=objectPossibility(:,1)./max(objectPossibility(:,1));

a = 1 - exp(-2.5*a);

result = superpixelToPixel(a, superpixels);

path = 'E:\matlab1\main\work_cv\FastVideoSegment\Code\sun_RandomWalk\testRW';
for i = 1:length(result)
    name = fullfile(path, sprintf('test%d.jpeg', i));
     b = getHeatmap(result{i}, 1);
    imwrite(b, name,'jpeg');
end





