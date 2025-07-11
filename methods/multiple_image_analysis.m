function imgs = multiple_image_analysis(original_imgs,fig,varargin)
    % set optional variable
    p = inputParser;
    addParameter(p,'visualizeMatchedPoint',false);
    parse(p,varargin{:});
    visualizeMatchedPoint = p.Results.visualizeMatchedPoint;

    % check if original_img contains exactly 2 images
    if length(original_imgs) < 2
        error('Input must contain at least 2 images.');
    end
    
    imgs{1} = original_imgs{1}; % on transformation needed for the first img
    ref_img = original_imgs{1}; % image 1 reference
    %gtrafo = [1,0,0;0,1,0;0,0,1]; % general transformation matrix
    for i = 2:size(original_imgs,2)
        ref_img_for_transform = ref_img;    % For alignment direction (always 1st image)
        ref_img_for_fill = ref_img;         % For filling (it's the last picture after the alignment)
        cur_img = original_imgs{i};
        %ref_img = original_imgs{i-1};      %image i-1 reference

        %logStatus(fig,sprintf("process:%d/%d",i,length(original_imgs)-1));
        loginfo = [i-1,length(original_imgs)-1];
        [proc_ref, proc_cur] = preprocessing(ref_img_for_transform, cur_img);
        [trafo, status] = matching_loop(proc_ref, proc_cur, fig, loginfo, true, visualizeMatchedPoint);
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

    


