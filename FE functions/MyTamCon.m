function Y = MyTamCon(X)
try   %Error handling
    temp_tamp=TamuraTextures(X);
%Individual
catch d
    %If it fails.... make zeros
    disp('error in TamCon')
    temp_tamp=[0 0];
end
Y = temp_tamp(2); % take the second returned value

