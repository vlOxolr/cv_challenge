function imgs = multiple_image_analysis(original_imgs,varargin)
    % set optional variable
    p = inputParser;
    addParameter(p,'visualizeMatchedPoint',false);
    addParameter(p,'algorithm',"surf");
    parse(p,varargin{:});
    visualizeMatchedPoint = p.Results.visualizeMatchedPoint;
    algorithm = p.Results.algorithm;

    % check if original_img contains exactly 2 images
    if length(original_imgs) < 2
        error('Input must contain at least 2 images.');
    end
    
    imgs{1} = original_imgs{1};
    ref_img = original_imgs{1};%image 1 reference
    %gtrafo = [1,0,0;0,1,0;0,0,1]; % general transformation matrix
    for i = 2:size(original_imgs,2)
         ref_img_for_transform = original_imgs{1};     % For alignment direction (always 1st image)
         ref_img_for_fill = imgs{i-1};                % For filling (it's the last picture after the alignment)
         cur_img = original_imgs{i};
        %ref_img = original_imgs{i-1};%image i-1 reference
        [proc_ref, proc_cur] = preprocessing(ref_img_for_transform, cur_img);
        [trafo,status] = matching_ROI(proc_ref, proc_cur, visualizeMatchedPoint,algorithm);
        %gtrafo = double(trafo.A) * gtrafo;
        
        %outputView = imref2d(size(img1));
        if status == 0
            corrected_img = trafo_correction(cur_img, trafo);%simtform2d(gtrafo));
            %corrected_img = align_and_fill(original_imgs{i}, ref_img, trafo);
            % make imgAafter complete using imgB
            corrected_img(corrected_img==0)=ref_img_for_fill(corrected_img==0);
            imgs{end+1} = corrected_img;
        else
            warning('Image %d could not be matched and was skipped.', i);
        end
    end
end

    


