%Script used to demonstrate isotropic/anisotropic diffusion on a
%Cartesian image.
%
%
%5/31/03 - Leo Grady

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
% Date - $Id: diffusionDemo.m,v 1.3 2003/08/21 17:29:29 lgrady Exp $
%========================================================================%

%Intialization
iterationsIso=60;
iterationsAniso=60;
valScale=10;

%Load image to import
img=im2double(imread('./../images/eslab0059.jpg'));
img=rgb2gray(img);
img=imresize(img,[320 256]); %Make smaller to run faster
[X Y Z]=size(img);

%Generate graph
[points edges]=lattice(X,Y);

%Perform isotropic diffusion
L=laplacian(edges);
diffusionVals1=diffusion(L,img(:),iterationsIso);

%Perform anisotropic diffusion
weights=makeweights(edges,img(:),valScale);
L=laplacian(edges,weights);
diffusionVals2=diffusion(L,img(:),iterationsAniso);

%Display
figure
subplot(1,3,1)
imagesc(img)
axis equal
axis tight
axis off
colormap(gray)
title('Original image: ESLab0059')

subplot(1,3,2)
imagesc(reshape(diffusionVals1,[X Y]))
axis equal
axis tight
axis off
colormap(gray)
title('Isotropic diffusion')

subplot(1,3,3)
imagesc(reshape(diffusionVals2,[X Y]))
axis equal
axis tight
axis off
colormap(gray)
title('Anisotropic diffusion')
