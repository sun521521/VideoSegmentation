%Script used to regionally sample and perform anisotropic 
%interpolation on an image
%
%
%5/21/03 - Leo Grady

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
% Date - $Id: cartesianAnisotropicDemo.m,v 1.2 2003/08/21 17:29:29 lgrady Exp $
%========================================================================%

%Initialization
scale=30;
samples=4000;
threshhold=8e-5;
sigma=.2;

%Read image
img=im2double(imread('./../images/lenna.gif'));
[X Y]=size(img);

%Create lattice
[points edges]=lattice(X,Y);
vals=img(:);

%Make weights
weights=makeweights(edges,vals,scale);

%Create weighted Laplacian matrix
L=laplacian(edges,weights);

%Generate samples
sampIndex=sub2ind([X Y],round(X/15*randn(1,samples)+X/2), ...
    round(Y/15*randn(1,samples)+Y/2));
dummy=zeros(1,X*Y);
dummy(sampIndex)=1;
sampIndex=find(dummy); %Used to avoid duplicates

%Center sampling
gaussVals=exp(sigma*sqrt((points(:,1)-Y/2).^2+(points(:,2)-X/2).^2));
gaussVals=gaussVals./sum(gaussVals); %Force sum to unity for probability
gaussImg=reshape(gaussVals,[X Y]);
[points2,edges2]=pdf2graph(gaussImg,samples);
points2=round(normalize(points2).*(ones(length(points2),1)*[Y-1,X-1])+1);
sampIndex2=sub2ind([X Y],points2(:,2),points2(:,1));
dummy=zeros(1,X*Y);  %Remove possible duplicate indices
dummy(sampIndex2)=1;
sampIndex2=find(dummy);

%Perform interpolation
newVals=dirichletboundary(L,sampIndex,vals(sampIndex));
newVals2=dirichletboundary(L,sampIndex2,vals(sampIndex2));

%Reshape
imgInterp=reshape(newVals,[X Y]);
imgInterp2=reshape(newVals2,[X Y]);

%Display sampled pixels
figure
subplot(2,2,1)
plot(points(sampIndex,1),Y-points(sampIndex,2),'k.','MarkerSize',24)
colormap(gray)
title('Center sampling')
axis([1 X 1 Y])
axis equal
axis off

subplot(2,2,2)
plot(points(sampIndex2,1),Y-points(sampIndex2,2),'k.','MarkerSize',24)
colormap(gray)
title('Peripheral Sampling')
axis([1 X 1 Y])
axis equal
axis off

subplot(2,2,3)
imagesc(imgInterp)
colormap(gray)
title('Center-based Interpolation')
axis image
axis off

subplot(2,2,4)
imagesc(imgInterp2)
colormap(gray)
title('Peripheral-based Sampling')
axis image
axis off
