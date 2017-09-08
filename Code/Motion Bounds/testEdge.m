function testEdge(boundaryMap)

edge = boundaryMap > 0.5;
edge3(:,:,1) = edge ; edge3(:,:,2) = edge ; edge3(:,:,3) = edge;

img = imread('E:\matlab1\main\work_cv\FastVideoSegment\Data\inputs\monkeydog\00000001.jpg');
[height width anyvalues] = size(img);

if max(height,width) > 400
    img = imresize(img,400/max(height,width));
end
imshow(uint8(~double(edge3) .* double(img)))