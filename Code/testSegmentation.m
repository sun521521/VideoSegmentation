function  testSegmentation(segmentation, i )

if nargin < 2 || isempty(i)
    i=1;
end

frames = length(segmentation) - 1;
 path = fullfile('E:\matlab1\main\work_cv\FastVideoSegment\Code\testSegmentation',sprintf('%d',i));
for frame  = 1:frames
   
            name = fullfile(path, sprintf('frame_%d.jpg',frame));
    imwrite(segmentation{frame},name);
end