function Y = MyTamDir(X)
try   %Error handling
    temp_tamp=TamuraTextures(X);
%Individual
catch
    %If it fails.... make zeros
    disp('error in TamDir')
    temp_tamp=[0 0];
end
Y = temp_tamp(1);

