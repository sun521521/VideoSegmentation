function [aa ,same, bb ,diff]=testYiZhiXing(superpixels, sNewSource, sNewDestination,  sNewWeights )

% file = ['D:\1研究生专用\项目\DAVIS_1\Annotations\480p\hike'];
file = ['C:\Users\Dorsey\Desktop\SegTrackv2实验结果\overlaid\groundtruth_bw\parachute'];

qian = []; bei = [];
for frame = 2:  27 % frames
    name = fullfile(file, sprintf('%05u.png', frame));  %%%%%%%%
    ground = imread( name );
    
%     if max(size(ground))>400
%         ground = imresize(ground, 400/max(size(ground)));
%     end
%     
    ground = im2bw(ground);
    
    sp = superpixels{frame};
    qianSets = ground.*double(sp);   qianSets  = qianSets(qianSets ~= 0);
    beiSets = ~ground .* double(sp);   beiSets =beiSets(beiSets~=0);
    
    uniqueSp = unique(sp);
    qianPer = [];  beiPer = [];
    for i = 1:length(uniqueSp)
        if sum( uniqueSp(i) == qianSets) > sum( uniqueSp(i) == beiSets);
            qianPer = [qianPer; uniqueSp(i)];
        else
            beiPer = [beiPer; uniqueSp(i)];
        end
    end
    qian = [qian ;qianPer];  bei = [bei; beiPer];
end

% index1 = (ismember(sNewSource, qian) & ismember( sNewDestination, qian))|(ismember(sNewSource, bei)&ismember( sNewDestination, bei));
index1 = (ismember(sNewSource, qian) & ismember( sNewDestination, qian));
same =  sNewWeights(index1);

index2 = (ismember(sNewSource, qian)&ismember( sNewDestination, bei))|(ismember(sNewSource, bei)&ismember( sNewDestination, qian));
diff =  sNewWeights(index2);


figure
% plot(same, '*');
aa=hist(same,30);
bar(min(same):(max(same)-min(same))/29:max(same),100*aa./sum(aa));

hold on 
% plot(diff,'o')
bb=hist(diff,30);
bar(min(diff):(max(diff)-min(diff))/29:max(diff),100*bb./sum(bb));