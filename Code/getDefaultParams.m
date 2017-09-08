% Function to provide some sane parameters. Not optimised for anything
%
%    Copyright (C) 2013  Anestis Papazoglou
%
%    You can redistribute and/or modify this software for non-commercial use
%    under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%    For commercial use, contact the author for licensing options.
%
%    Contact: a.papazoglou@sms.ed.ac.uk

function params = getDefaultParams()

    params.fadeout = 0.0001;   % 外观模型中的 消失率参数
    params.foregroundMixtures = 5; % 前景模型中的高斯模型 个数
    params.backgroundMixtures = 8;
    params.maxIterations = 3;   %%%%% 4
    
    

    %   breakdance-flare:   a2 = 1.5
      a1 = 1; L1 = 1.5; LA1 = 1;    a2 = 0.75; L2 = 1.25; LA2 = 0.75; O2 = 3.5;    S = 100; T = 50; TD = 1.5;   % seg


    
    params.appearanceWeight1 = a1;
    params.locationWeight1 = L1;  
    params.laWeight1 = LA1;  
        
    
      params.appearanceWeight2 = a2; 
    params.locationWeight2 =  L2;  
    params.laWeight2 = LA2;  
    params.objectWeight = O2; 
    
    
     params.spatialWeight = S; 
    params.temporalWeight = T ; 
    params.tdWeight = TD; 
    
end

