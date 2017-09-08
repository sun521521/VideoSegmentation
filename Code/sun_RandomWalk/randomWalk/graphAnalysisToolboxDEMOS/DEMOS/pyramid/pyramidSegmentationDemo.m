%Compute a segmentation using a pyramid architecture.
%
%Note: The script takes a couple minutes to run.
%
%
%6/5/03 - Leo Grady

% Copyright (C) 2002, 2003 Leo Grady <lgrady@cns.bu.edu>
%   Computer Vision and Computational Neuroscience Lab
%   Department of Cognitive and Neural Systems
%   Boston University
%   Boston, MA  02215
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
%
% Date - $Id: pyramidSegmentationDemo.m,v 1.4 2003/08/21 17:29:30 lgrady Exp $
%========================================================================%

%Initialization
scale=180;
stop=1e-5;
levels=3;

%Read image
img=im2double(imread('./../images/blood1.tif'));

%Resize to make script run faster
[X Y Z]=size(img);
img=imresize(img,[floor(X/2),floor(Y/2)]);
[X Y Z]=size(img);

%Perform segmentation
[imgMasks,imgMarkup,segOutline,treeImg]= ...
    imgsegpyr(img,scale,stop,levels);

%Display
figure
subplot(3,1,1)
imagesc(img)
axis equal
axis tight
axis off
colormap(gray)
title('Original image')

subplot(3,1,2:3)
imagesc(treeImg)
axis equal
axis tight
axis off
colormap(gray)
title('Segmentation at different levels')
