function imgs = multiple_image_analysis(original_imgs)
    % check if original_img contains exactly 2 images
    if length(original_imgs) < 2
        error('Input must contain at least 2 images.');
    end
    
    imgs{1} = original_imgs{1};
    ref_img = original_imgs{1};%image 1 reference
    %gtrafo = [1,0,0;0,1,0;0,0,1]; % general transformation matrix
    for i = 2:size(original_imgs,2)
        matching_ref_img = original_imgs{i-1};     
        cur_img = original_imgs{i};
        align_ref_img = original_imgs{1};
        %ref_img = original_imgs{i-1};%image i-1 reference
        [proc_ref, proc_cur] = preprocessing(matching_ref_img, cur_img);
        [trafo,status] = SURFmatching(proc_ref, proc_cur, false);
        %gtrafo = double(trafo.A) * gtrafo;
        fill_img = imgs{i-1};
        %outputView = imref2d(size(img1));
        if status == 0
            corrected_img = trafo_correction(cur_img, trafo);  
            corrected_img(corrected_img==0) = fill_img(corrected_img==0);
            imgs{end+1} = corrected_img;
        else
            warning('Image %d could not be matched and was skipped.', i);
        end
    end

    


