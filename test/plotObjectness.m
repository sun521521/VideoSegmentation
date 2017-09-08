function plotObjectness(groundtruth, img, state)

[height, width,any] = size(groundtruth);
sup = ones(height, width);

for i = 1:height
    for j = 3:width
        if groundtruth(i, j) ~= groundtruth(i, j-1);
            sup(i, j+1) = 0;
            sup(i, j) = 0;
            sup(i, j-1) = 0;
             sup(i, j-2) = 0;
        end
    end
end
for c = 1:3
    sup1(:,:, c) = sup;
end

sup = ones(height, width);
for i = 3:height
    for j = 1:width
        if groundtruth(i, j) ~= groundtruth(i-1, j);
            sup(i+1, j) = 0;
            sup(i, j) = 0;
            sup(i-1, j) = 0;
            sup(i-2, j) = 0;
        end
    end
end
for c = 1:3
    sup2(:,:, c) = sup;
end

supp = sup1.* sup2;
% supp(supp(:,:,1)==0) = 255;
img = double(img);
img(supp == 0) = 0;
% result = img.* supp;
result = uint8(img);
% imshow(result);

if state == '1'
imwrite(result, 'appearanceImg.jpeg');
end
if state == '2'
imwrite(result, 'LA1.jpeg');
end
if state == '3'
imwrite(result, 'locationImg.jpeg');
end
if state == '4'
imwrite(result, 'object1.jpeg');
end