function beta1 = sun_learnBeta( options, superpixels, NewSource, NewDestination, dij, cij, sBeta, mode)

learnFrames  = 2;   trainRatio = 0.3 ;
maxItera = 300; lamda = 0.2;
groundTruth = dir(fullfile(options.infolder, 'ground-truth','*.png'));


for frame = 1:learnFrames
    superFrame{frame} = superpixels{frame};
    ground{frame} = im2bw(imread(fullfile(options.infolder, 'ground-truth',groundTruth(frame).name))); 
end

if (mode == 'v'|| mode == 'V')
    foregroundNodes = []; backgroundNodes = [];
    
    for i = 1:learnFrames
        fore = ground{i}.*double(superFrame{i}); fore = fore(fore ~= 0);
        back = ~ground{i} .* double(superFrame{i}); back = back(back ~= 0);
          foregroundNodes = [foregroundNodes; reshape(fore, [], 1)]; backgroundNodes = [backgroundNodes; reshape( back , [], 1)];
    end
    
    sameIndex = (ismember(NewSource, foregroundNodes)&ismember( NewDestination, foregroundNodes))|(ismember(NewSource, backgroundNodes)&ismember( NewDestination, backgroundNodes));
      sameSource  = NewSource(sameIndex);       sameDestination  = NewDestination(sameIndex);
      sameDij = dij(sameIndex);       sameCij = cij(sameIndex); sameYij = ones(size(sameCij));

    diffIndex = (ismember(NewSource, foregroundNodes)&ismember( NewDestination, backgroundNodes))|(ismember(NewSource, backgroundNodes)&ismember( NewDestination, foregroundNodes));
      diffSource  = NewSource(diffIndex);       diffDestination  = NewDestination(diffIndex);
      diffDij = dij(diffIndex);       diffCij = cij(diffIndex); diffYij = -ones(size(diffCij));
      
      % 可加上去噪
      
    %  同类训练样本    
          sameIndex = [1:sum(sameIndex)]'; %% 
      samePerm = randperm(length( sameIndex ))';  %% 
      trainSameIndex = sameIndex(samePerm(1:floor(length(sameIndex)*trainRatio) ) ); 
      trainSameData(:, 1) = double(sameSource(trainSameIndex));  trainSameData(:, 2) = double(sameDestination(trainSameIndex));
      trainSameData(:, 3) = sameDij(trainSameIndex);  trainSameData(:, 4) = sameCij(trainSameIndex); trainSameData(:, 5) = sameYij(trainSameIndex);

    % 同类测试样本
      testSameIndex = ~ismember(sameIndex, trainSameIndex);
     testSameData(:, 1) = double(sameSource(testSameIndex));  testSameData(:, 2) = double(sameDestination(testSameIndex));
     testSameData(:, 3) = sameDij(testSameIndex);  testSameData(:, 4) = sameCij(testSameIndex); testSameData(:, 5) = sameYij(testSameIndex);

      
        %  异类训练样本    
           diffIndex = [1:sum(diffIndex)]'; %% 
      diffPerm = randperm(length( diffIndex ))';  %% 
      trainDiffIndex = diffIndex(diffPerm(1:floor(length(diffIndex)*trainRatio)) ); 
      trainDiffData(:, 1) = double(diffSource(trainDiffIndex));  trainDiffData(:, 2) = double(diffDestination(trainDiffIndex));
      trainDiffData(:, 3) = diffDij(trainDiffIndex);  trainDiffData(:, 4) = diffCij(trainDiffIndex); trainDiffData(:, 5) =diffYij(trainDiffIndex);

    % 异类测试样本
      testDiffIndex = ~ismember(diffIndex, trainDiffIndex);
     testDiffData(:, 1) = double(diffSource(testDiffIndex));  testDiffData(:, 2) = double(diffDestination(testDiffIndex));
      testDiffData(:, 3) = diffDij(testDiffIndex);   testDiffData(:, 4) = diffCij(testDiffIndex);  testDiffData(:, 5) = diffYij(testDiffIndex);
     
      % 所有的训练和测试样本
     trainData = double([trainSameData; trainDiffData]);   testData = double([ testSameData;  testDiffData]);
     
     beta0 = sBeta;  t0 = 0.5;  
     for itera = 1:maxItera
         sampleId = ceil(length(trainData)*rand(1));
         
         yij = trainData(sampleId, 5);  dij = trainData(sampleId, 3); cij = trainData(sampleId, 4);
         if ( yij * (dij * exp(-beta0 * cij) - t0) < 1 )
             beta1 = beta0 - lamda * yij * (dij * cij *exp(-beta0 * cij));
             t1 = t0 - lamda * yij;   %%%%
         end
         
       y = testData(:, 5);  d = testData(:, 3); c = testData(:, 4);
            obj(itera) = sum(max(1-y.*(d.*exp(-beta1.*c) - t1), 0))
       if itera ~= 1 && obj(itera) > obj(itera-1), beta1 = beta0; return; end
       
       % 画出目标函数在每次迭代中的值
        figure(1) ;
        h = plot(1,obj(1));
        set(h,'XData',[1: itera],'YData',obj(1: itera));
        drawnow;
        pause(0.01);
        
          beta0 = beta1;  t0 = t1;
     end
    
end

    
    
    