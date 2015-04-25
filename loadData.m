%    ImageFARMER-rewrite Feature Data loading function
%    Copyright (C) 2015  Patrick McInerney
%    Contact: pmmciner@gmail.com
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
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
%   [FD, imageClassLabels] = loadData(FDPath,imageClassLabelsPath)
%    
%   Utility function for loading output of the Feature Extraction Module
%   needed for the other modules

function [FD, imageClassLabels] = loadData(FDPath,imageClassLabelsPath)

    if(exist(FDPath,'file'))
      s = load(FDPath,'FD');
      FD = s.FD;
    else
      error('no Extracted Features found. Try running the Feature Extraction Module and/or checking your paths.');
    end
    if(exist(imageClassLabelsPath,'file'))
      s = load(imageClassLabelsPath,'imageClassLabels');
      imageClassLabels = s.imageClassLabels;
    else
      error('no class labels found. Try running the Feature Extraction Module and/or checking your paths.');
    end
