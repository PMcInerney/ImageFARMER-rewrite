function Fdir = MyTamDir(Im)
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
