function test_find( seeds, superpixels)

for m = 1:length(superpixels)-1
    img = imread(['E:\matlab1\main\work_cv\FastVideoSegment\Data\inputs\hike\' sprintf('%05u.jpg', m)]);  %%%
    img = rgb2gray(img);
    if max(size(img))>400
        img = imresize(img, 400/max(size(img)));
    end
    % img = imresize(img , 400/max(size(img)));
    
    
    for i = 1:length(seeds)
        index = superpixels{m}==seeds(i);  %%%%
        img(index) = 0;
    end
    imshow(img);
    pause(2)
end