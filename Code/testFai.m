function testFai(superpixels, flow)

a = superpixels{1};
b = superpixels{2};

u = flow{1}(:,:,2);
v = flow{1}(:,:,1);

u = reshape(u,[], 1);
v = reshape(v,[], 1);
index = find(a==56);

[height width] = size(a);
newIndex = index + double(u(index))*height + double(v(index));
newIndex = newIndex(newIndex > 0 & newIndex <=height *width);

bIndex = find(b==1384);

fai  = length(intersect(newIndex,bIndex))/length(newIndex)


