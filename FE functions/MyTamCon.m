function Fc = MyTamCon(Im)
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
