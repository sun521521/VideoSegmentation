

frame = 25; 

index = seeds1 >= bounds(frame) & seeds1 < bounds(frame+1);
currentSeed = seeds1(index);

img = imread('C:\Users\Dorsey\Desktop\davis实验结果\overlaid\my_method_onestage\drift-chicane\00025.jpg');
mask = superpixels{frame};

for i = 1:length(currentSeed )
  
    c=img(:,:,2);  
        c(mask ==currentSeed(i) ) = 175;  
        img(:,:,2) = uint8(c); 
        
         b=img(:,:,1); bb = b(mask ==currentSeed(i));     b(mask ==currentSeed(i) ) = ceil((double(bb)./double(255))*100); img(:,:,1) = uint8(b);
          s=img(:,:,3); ss = s(mask ==currentSeed(i) );     s(mask ==currentSeed(i) ) = ceil((double(ss)./double(255))*100); img(:,:,3) = uint8(s);
end
imwrite(img, 'seeds.jpeg','jpeg');