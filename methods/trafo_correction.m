function corrected_img = trafo_correction(img,trafo)
    % transformation correction
    outputView = imref2d(size(img));
    corrected_img = imwarp(img,invert(trafo),"OutputView",outputView);    
end