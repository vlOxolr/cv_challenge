function imgs = multiple_image_analysis(original_imgs)
    % check if original_img contains exactly 2 images
    if length(original_imgs) < 2
        error('Input must contain at least 2 images.');
    end
    
    imgs{1} = original_imgs{1};
    %gtrafo = [1,0,0;0,1,0;0,0,1]; % general transformation matrix
    for i = 2:size(original_imgs,2)
        img1 = original_imgs{1};
        img2 = original_imgs{i};

        [img1,img2] = preprocessing(img1,img2);
        [trafo,status] = SURFmatching(img1,img2,false);
        %gtrafo = double(trafo.A) * gtrafo;

        if status == 0
            corrected_img = trafo_correction(original_imgs{i},trafo);%simtform2d(gtrafo));
            imgs{end+1} = corrected_img;
        end
    end
end