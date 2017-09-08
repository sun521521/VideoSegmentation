function testFilled(inRatios, superpixels, data, T)

a = inRatios{1}; 
img = data.imgs{1};

b = superpixels{1}; 
[height, width] = size(b);

c = double(data.edgePoints{1});

% 大于阈值的块全部填充为1
needToFill = find( a > T);  % 阈值填充

f = false(height, width);
for i = 1:length(needToFill)
    f(b == needToFill(i)) = true;
end
figure(1)
imshow(logical(f));

s = double(b);
jiao =  false(height, width);
% 与边界相交的超像素块
in = unique(s .* c);  in = in(in ~= 0);
for i = 1:length(in)
    jiao(b == in(i)) = true;
end
figure(2)
imshow(logical(jiao));

nei = false(height, width);
wai = false(height, width);
% 内部、外部边缘块
lamdaNei = 0.7;   lamdaWai = 0.5;  
for i = 1:length(in)
    if a(in(i)) > 0.5*lamdaNei && a(in(i)) < 1*lamdaNei
        nei(b == in(i)) = true;
    elseif a(in(i)) > 0.2*lamdaWai && a(in(i)) < 0.5*lamdaWai
        wai(b == in(i)) = true;
    end
end

nei3(:,:,1) = nei; nei3(:,:,2) = nei; nei3(:,:,3) = nei;
wai3(:,:,1) = wai; wai3(:,:,2) = wai; wai3(:,:,3) = wai;
figure(8)
imshow(uint8(~double(nei3) .* double(img)))
figure(9)
imshow(uint8(~double(wai3) .* double(img)))



