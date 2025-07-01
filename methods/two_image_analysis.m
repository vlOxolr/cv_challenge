function imgs = two_image_analysis(original_imgs)

    % check if original_img contains exactly 2 images
    if size(original_imgs,2) ~= 2
        error('Input must contain exactly 2 images.');
    end

    % store image
    img1 = original_imgs{1};
    img2 = original_imgs{2};
    
    % convert to gray image
    img1 = rgb2gray(img1);
    img2 = rgb2gray(img2);

    % histogram equalization
    img1 = histeq(img1);
    img2 = histeq(img2);

    % histogram match
    img2 = imhistmatch(img2, img1);
    
    % edge detection
    %thres = 0.5;
    %img1 = edge(img1, 'Canny', thres);
    %img2 = edge(img2, 'Canny', thres);

    % prefiltering
    %w=fir1(20,0.5);
    %kernel = w'*w;
    %kernel = kernel / sum(kernel(:));% normalize
    %img1 = convn(img1, kernel, 'same');
    %img2 = convn(img2, kernel, 'same');
    
    % feature extraction and matching
    points1 = detectSURFFeatures(img1);
    points2 = detectSURFFeatures(img2);
    
    [features1, validPoints1] = extractFeatures(img1, points1);
    [features2, validPoints2] = extractFeatures(img2, points2);
    
    indexPairs = matchFeatures(features1, features2);
    
    matchedPoints1 = validPoints1(indexPairs(:, 1));
    matchedPoints2 = validPoints2(indexPairs(:, 2));

    % fundamental matrix
    matchedPoints1 = matchedPoints1.Location;
    matchedPoints2 = matchedPoints2.Location;
    
    tform = estgeotform2d(matchedPoints1,matchedPoints2,"similarity");
    tform

    outputView = imref2d(size(img1));
    corrected_img = imwarp(original_imgs{1},tform,"OutputView",outputView);
 
    imgs = {corrected_img,original_imgs{2}};

end