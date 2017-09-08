%Script used to treat anisotropic interpolation on an image as a low-pass filter.
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
% Date - $Id: interpolationFilterDemo.m,v 1.3 2003/08/21 17:29:29 lgrady Exp $
%========================================================================%

%Initialization
scale=100;
samples=5000;
threshhold=8e-5;

%Read image
img=im2double(imread('./../images/lenna.gif'));
[X Y]=size(img);

%Create lattice
[points,edges]=lattice(X,Y);
vals=img(:);

%Make weights
weights=makeweights(edges,vals,scale);

%Create weighted Laplacian matrix
L=laplacian(edges,weights);

%Generate samples
A=incidence(edges);
grads=A*img(:);
energy=abs(A)'*(grads.*grads);
sampIndex=find(energy<threshhold);
vals=img(:);

%Perform interpolation
newVals=dirichletboundary(L,sampIndex,vals(sampIndex));

%Reshape
imgInterp=reshape(newVals,[X Y]);

%Display sampled pixels
imgSamp=zeros(X,Y);
imgSamp(sampIndex)=vals(sampIndex);
figure
subplot(2,2,1)
imagesc(img)
axis image
colormap(gray)
axis off
title('Original Image')

subplot(2,2,2)
plot(points(sampIndex,1),Y-points(sampIndex,2),'k.','MarkerSize',24)
axis image
colormap(gray)
axis off
title('Sampled pixels')

subplot(2,2,3)
imagesc(reshape(energy,[X Y]))
axis image
colormap(gray)
axis off
title('Magnitude of image gradients')

subplot(2,2,4)
imagesc(imgInterp)
axis image
colormap(gray)
axis off
title('Anisotropic Interpolation')
