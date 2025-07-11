function [matched,imgs,highlights] = two_image_analysis(original_imgs,fig,varargin)

    % set optional variable
    p = inputParser;
    addParameter(p,'visualizeMatchedPoint',false);
    parse(p,varargin{:});
    visualizeMatchedPoint = p.Results.visualizeMatchedPoint;

    % check if original_img contains exactly 2 images
    if size(original_imgs,2) ~= 2
        error('Input must contain exactly 2 images.');
    end

    % store image
    img1 = original_imgs{1};
    img2 = original_imgs{2};
    
    [img1,img2] = preprocessing(img1,img2);
    if visualizeMatchedPoint
        showImg(img1,img2,"preprocessing result");
    end

    %img1 = imbinarize(img1,"adaptive");
    %img2 = imbinarize(img2,"adaptive");
    %if visualizeMatchedPoint
    %    showImg(img1,img2,"convert to binar image result");
    %end

    % prefiltering
    %w=fir1(1,[0.2,0.3]);
    %kernel = w'*w;
    %kernel = kernel / sum(kernel(:));% normalize
    %img1 = convn(img1, kernel, 'same');
    %img2 = convn(img2, kernel, 'same');

    % edge detection
    %thres = 0.01;
    %img1 = edge(img1, 'log', thres);
    %img2 = edge(img2, 'log', thres);
    %if visualizeMatchedPoint
    %    showImg(img1,img2,"edge detection result");
    %end

    loginfo = [1,1];
    [trafo,status] = matching_loop(img1, img2, fig, loginfo, false, visualizeMatchedPoint);

    if status == 0
        matched = true;

        ref_img_for_fill = original_imgs{1};
        corrected_img = trafo_correction(original_imgs{2},trafo);
        corrected_img(corrected_img==0)=ref_img_for_fill(corrected_img==0);
        imgs = {original_imgs{1},corrected_img};

        highlights = highlight(original_imgs{1},corrected_img);
    else
        matched = false;
        imgs = NaN;
        highlights = NaN;
    end
end

function showImg(img1,img2,text)
    figure;
    subplot(1,2,1);
    imshow(img1);
    title(text,'Image 1');
    
    subplot(1,2,2);
    imshow(img2);
    title(text,'Image 2');
end

function hl = highlight(img1,img2)
    [img1,img2] = preprocessing(img1,img2);
    
    diff = imabsdiff(img1, img2);

    threshold = 100;
    bmask = diff > threshold; % binar mask

    hl = cat(3, ones(size(bmask)), ones(size(bmask)), zeros(size(bmask))).*bmask;
end