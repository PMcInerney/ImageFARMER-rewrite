% Copyright (C) 2015 Patrick McInerney
% Copyright (C) 2003 Open Microscopy Environment
%       Massachusetts Institue of Technology,
%       National Institutes of Health,
%       University of Dundee
%
%
%
%    This library is free software; you can redistribute it and/or
%    modify it under the terms of the GNU Lesser General Public
%    License as published by the Free Software Foundation; either
%    version 3 of the License, or (at your option) any later version.
%
%    This library is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%    Lesser General Public License for more details.
%
%    You should have received a copy of the GNU Lesser General Public
%    License along with this library; If not, see 
%    <http://www.gnu.org/licenses/>.
%
% 
% Fc = TamuraContrast(Im) returns the Tamura Contrast of image Matrix Im.

% This code was written by Nikita Orlov <norlov@nih.gov> as part of a
% larger function, and was extracted and replicated here for simplified use
function Fc = TamuraContrast(Im)
    if ~isa(Im,'double')
        Im = im2double(Im);
    end
    try   %Error handling
        Im = Im(:)';
        ss = std(Im); 
        if abs(ss)<1e-10, 
            Fc = 0;
        else
            k = kurtosis(Im);
            alf = k ./ ss.^4;
            Fc = ss./(alf.^(.25));
        end
    catch d
        %If it fails.... make zeros
        warning('error in TamCon\n %s', d.message)
        Fc=0;
    end
