function plotSuper(superpixels)

superpixel = superpixels{25};
img = imread('C:\Users\Dorsey\Desktop\davis实验结果\inputs\drift-chicane\00025.jpg');

if max(size(img))>400
    img = imresize(img, 400/max(size(img)));
end

[height, width] = size(superpixel);
sup = ones(height, width);

for i = 1:height
    for j = 2:width
        if superpixel(i, j) ~= superpixel(i, j-1);
            sup(i, j) = 0;
            %             sup(i, j-1) = 0;
        end
    end
end
for c = 1:3
    sup1(:,:, c) = sup;
end

sup = ones(height, width);
for i = 2:height
    for j = 1:width
        if superpixel(i, j) ~= superpixel(i-1, j);
            sup(i, j) = 0;
            %             sup(i-1, j) = 0;
        end
    end
end
for c = 1:3
    sup2(:,:, c) = sup;
end

supp = sup1.* sup2;
supp(supp(:,:,1)==0) = 255;
img = double(img);
result = img.* supp;
result = uint8(result);
imshow(result);
imwrite(result,'result.jpeg','jpeg')
