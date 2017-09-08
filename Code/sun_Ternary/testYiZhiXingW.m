function [aa ,same, bb ,diff]=testYiZhiXingW(superpixels, tNewSource, tNewDestination,  tNewWeights)

file = ['D:\1研究生专用\项目\DAVIS_1\Annotations\480p\flamingo'];

qian1 = []; bei1 = []; qian2 = []; bei2 = [];

for frame = 1:  14 % frames
    name1 = fullfile(file, sprintf('%05u.png', frame));
    name2 = fullfile(file, sprintf('%05u.png', frame+1));
    
    
    ground1 = imread(name1);
    ground2 = imread(name2);
    
    if max(size(ground1))>400
        ground1  = imresize(ground1 , 400/max(size(ground1 )));
        ground2  = imresize(ground2 , 400/max(size(ground2)));
    end
    
    
    ground1 = im2bw(ground1); ground2 = im2bw(ground2);
    
    sp = superpixels{frame};   ps = superpixels{frame+1};
    qian1Sets = ground1.*double(sp);   qian1Sets  = qian1Sets(qian1Sets ~=0);
    qian2Sets = ground2.*double(ps);   qian2Sets  = qian2Sets(qian2Sets ~=0);
    
    
    bei1Sets = ~ground1 .* double(sp);   bei1Sets =bei1Sets(bei1Sets~=0);
    bei2Sets = ~ground2 .* double(ps);   bei2Sets =bei2Sets(bei2Sets~=0);
    
    
    
    uniqueSp = unique(sp);
    qian1Per = [];  bei1Per = [];
    for i = 1:length(uniqueSp)
        if sum( uniqueSp(i) == qian1Sets) > sum( uniqueSp(i) == bei1Sets);
            qian1Per = [qian1Per; uniqueSp(i)];
        else
            bei1Per = [bei1Per; uniqueSp(i)];
        end
    end
    qian1 = [qian1;qian1Per];  bei1 = [bei1; bei1Per];
    
    uniquePs = unique(ps);
    qian2Per = [];  bei2Per = [];
    for i = 1:length(uniquePs)
        if sum( uniquePs(i) == qian2Sets) > sum( uniquePs(i) == bei2Sets);
            qian2Per = [qian2Per; uniquePs(i)];
        else
            bei2Per = [bei2Per; uniquePs(i)];
        end
    end
    qian2 = [qian2;qian2Per];  bei2 = [bei2; bei2Per];
    
end




% index1 = (ismember(tNewSource, qian1)&ismember( tNewDestination, qian2))|(ismember(tNewSource, bei1)&ismember( tNewDestination, bei2));
index1 = (ismember(tNewSource, qian1)&ismember( tNewDestination, qian2));
same = tNewWeights(index1);

index2 = (ismember(tNewSource, qian1)&ismember( tNewDestination, bei2))|(ismember(tNewSource, bei1)&ismember( tNewDestination, qian2));
diff = tNewWeights(index2);


figure
% plot(same, '*');
aa=hist(same,30);
bar(min(same):(max(same)-min(same))/29:max(same),aa./sum(aa));


figure
% plot(diff,'o')
bb=hist(diff,30);
bar(min(diff):(max(diff)-min(diff))/29:max(diff),bb./sum(bb));