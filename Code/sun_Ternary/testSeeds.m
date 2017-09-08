function testSeeds(imgs, unaryPotential, superpixels, bounds)
% testSeeds(data.imgs, data.unaryPotential, superpixels, bounds)


% % 全局
% beta = 0.84;
% maxPossibility = maxmax(cell2mat(unaryPotential));
% threshold = maxPossibility * beta;

frames = length( unaryPotential );

seeds = [];
for frame = 1:frames
    % 局部
    beta1 = 0.90;
   beta2 = 0.95;
  maxPossibility = maxmax(unaryPotential{frame});
   threshold1  = maxPossibility * beta1;
      threshold2  = maxPossibility * beta2;

    superFrame = superpixels{frame};
    seed = superFrame(unaryPotential{frame} >= threshold1 & unaryPotential{frame} <= threshold2);
    seed  = reshape(seed, [], 1);
     seeds = [seeds; seed];
end

nodes = bounds(frames+1) -1;
mask = ones(nodes, 1);
mask(seeds, 1) = 0;

result = superpixelToPixel(mask, superpixels);

path = 'E:\matlab1\main\work_cv\FastVideoSegment\Code\sun_Ternary\testSeeds';
temp = zeros(size(imgs{1}));
for i = 1:frames
    temp(:,:,1) = result{i}; temp(:,:,2) = result{i}; temp(:,:,3) = result{i};
    output =  temp .* double(imgs{i});
    name = fullfile(path, sprintf('test%d.jpg', i));
    imwrite(uint8(output), name);
end







