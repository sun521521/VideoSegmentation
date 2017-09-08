%Script used to find and display ellipses that correspond to the Voronoi 
%cells of a point set.
%
%
%5/15/03 - Leo Grady

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
% Date - $Id: ellipseDisplayDemo.m,v 1.3 2003/08/21 17:29:30 lgrady Exp $
%========================================================================%

OFFSET=.5;

%Parameters
N=20;
F=.8;
samps=500;

%Generate points
points=.1*randn(N,2)+.5;
minX=0;
maxX=1;
minY=0;
maxY=1;        
points=normalize(points,[minX,minY;maxX,maxY]);

%Add border pixels
halfN=ceil(N/2);
widthBorder=linspace(minX-OFFSET,maxX+OFFSET,halfN)';
widthBorder=widthBorder(2:(end-1));
heightBorder=linspace(minY-OFFSET,maxY+OFFSET,halfN)';
points=[points;[minX*ones(halfN,1)-OFFSET;maxX*ones(halfN,1)+OFFSET; ...
            widthBorder;widthBorder],[heightBorder;heightBorder; ...
            minY*ones(halfN-2,1)-OFFSET;maxY*ones(halfN-2,1)+OFFSET]]; 
            %OFFSET used to give a small buffer around node cluster

%Find voronoi cells
[vpoints, vcells] = voronoin(points);

%Find infinity point
infPoints=find(vpoints(:,1)==Inf);

%Initialize arrays
coeffs=zeros(1,3);
centroid=zeros(1,2);

%Find and draw ellipses
figure
imgEllipse=zeros(length(0:1/samps:1),length(0:1/samps:1));
hold on
[x y]=meshgrid(0:1/samps:1,0:1/samps:1);
for k=1:N
    if(isempty(intersect(vcells{k},infPoints)))
        %Find ellipse
        [dummy1, dummy2]=ellipsefit(vpoints(vcells{k},:),F);
        coeffs(k,:)=dummy1';
        centroid(k,:)=dummy2;
        
        %Draw ellipse        
        img=coeffs(k,1)*(x-centroid(k,1)).^2+ ...
            coeffs(k,2)*(x-centroid(k,1)).*(y-centroid(k,2))+ ...
            coeffs(k,3)*(y-centroid(k,2)).^2;
        index=find((F-img)>0);
        dummyImg=zeros(length(x),length(y));
        dummyImg(index)=1;
        [dx dy]=gradient(dummyImg);
        imgEllipse=imgEllipse+spones(abs(dx)+abs(dy));
    end
end

%Draw ellipse
imgEllipse=spones(imgEllipse);
imagesc(~imgEllipse);

%Add Voronoi cells
axis equal
voronoi(samps*points(:,1),samps*points(:,2),'k')
hold off
colormap(gray)
axis([0 samps 0 samps])
axis off
