function testThetaFenmu(dthetaMax)

theta = dthetaMax .* dthetaMax;  % 最大角度差的平方

a = reshape(theta,[],1);
figure(1)
hist(a,50)

b = a(a<3 & a>0.035);
figure (2) 
hist(b,50)


mu = mean(b)
st = std(b)

% b = sort(b);
% figure (3)
% plot(b, normpdf(b, 0.04, 0.5))

ctheta = normcdf(theta, 0.04, 0.5);
figure (4)
imshow(ctheta)
figure (5)
imshow(ctheta > 0.7)

old = 1 - exp(-theta);
figure(6)
imshow(old);
title('原始代码')