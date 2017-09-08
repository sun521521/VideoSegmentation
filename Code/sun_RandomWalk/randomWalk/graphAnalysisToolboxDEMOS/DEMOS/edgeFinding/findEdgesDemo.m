%Script used to demo edge finding on a Cartesian image.
%
%
%5/6/03 - Leo Grady

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
% Date - $Id: findEdgesDemo.m,v 1.3 2003/08/21 17:29:29 lgrady Exp $
%========================================================================%

%Parameters
scale=10;
iterations=15;

%Load image
img=im2double(imread('./../images/eslab0032.jpg'));
img=imresize(img,[256,320]); %Resize to a more manageable size
[X Y Z]=size(img);

%Build graph
[points edges]=lattice(X,Y);
N=size(points,2);
vals=rgbimg2vals(img,1);

%Blur via neighborhood averaging to even out noise
weights=makeweights(edges,vals,scale);
L=laplacian(edges,weights);
vals=diffusion(L,vals,iterations);

%Perform gradient threshholding edge detection
edgeNodes1=findedges(edges,vals,0);

%Perform Laplacian threshholding edge detection
edgeNodes2=findedges(edges,vals,1);

%Reform image
blurImg=reshape(vals(:,1),X,Y);
blurImg(:,:,2)=reshape(vals(:,2),X,Y);
blurImg(:,:,3)=reshape(vals(:,3),X,Y);
edgeImg1=zeros(X,Y);
edgeImg1(edgeNodes1)=1;
edgeImg2=zeros(X,Y);
edgeImg2(edgeNodes2)=1;

%Display
figure
subplot(2,2,1)
imagesc(img)
axis equal
axis tight
axis off
title('Original: eslab0032')

subplot(2,2,2)
imagesc(blurImg)
axis equal
axis tight
axis off
title('Blurred image')

subplot(2,2,3)
imagesc(edgeImg1)
axis equal
axis tight
axis off
colormap('gray')
title('Edges: Gradient threshholding')

subplot(2,2,4)
imagesc(edgeImg2)
axis equal
axis tight
axis off
colormap('gray')
title('Edges: Laplacian threshholding')
