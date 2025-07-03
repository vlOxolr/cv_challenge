function [matched,imgs,highlights] = two_image_analysis(original_imgs,varargin)

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

    [tform,status] = SURFmatching(img1,img2,visualizeMatchedPoint);
    
    % transformation correction
    outputView = imref2d(size(img1));
    corrected_img = imwarp(original_imgs{1},tform,"OutputView",outputView);
 
    imgs = {corrected_img,original_imgs{2}};
    
    if status ~= 0 || tform.A(3,3) <= 0.8
        matched = false;
    else
        matched = true;
    end

    highlights = highlight(corrected_img, original_imgs{2});
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

    threshold = 150;
    bmask = diff > threshold; % binar mask

    hl = cat(3, ones(size(bmask)), ones(size(bmask)), zeros(size(bmask))).*bmask;
end