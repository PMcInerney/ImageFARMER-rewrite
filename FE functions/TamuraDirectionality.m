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
% Fc = TamuraDirectionality(Im) returns the Tamura Directionality of
% image Matrix Im.

% This code was written by Nikita Orlov <norlov@nih.gov> as part of a
% larger function, and was extracted and replicated here for simplified use
function Fdir = TamuraDirectionality(Im)
    if ~isa(Im,'double')
        Im = im2double(Im);
    end
    try   %Error handling
        [gx,gy] = gradient(Im); 
        [t,r] = cart2pol(gx,gy);
        nbins = 125;
        r(r<.15.*max(r(:))) = 0; 
        t0 = t; t0(abs(r)<1e-4) = 0;
        r = r(:)'; t0 = t0(:)'; 
        Hd = hist(t0,nbins); 
        nrm = hist(r(:).^2+t0(:).^2,nbins); 
        fmx = find(Hd==max(Hd));
        ff  = 1:length(Hd); 
        ff2 = (ff - fmx).^2; 
        Fdir = sum(Hd.*ff2)./sum(nrm);
        Fdir = abs(log(Fdir+eps));
    catch d
        %If it fails.... make zeros
        warning('error in TamDir\n %s', d.message)
        Fdir=0;
    end
