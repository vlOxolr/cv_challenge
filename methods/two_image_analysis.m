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

    %img1 = edge_detection(img1);
    %img2 = edge_detection(img2);
    %if visualizeMatchedPoint
    %    showImg(img1,img2,"edge detection result");
    %end

    % edge detection
    %thres = 0.01;
    %img1 = edge(img1, 'log', thres);
    %img2 = edge(img2, 'log', thres);
    %if visualizeMatchedPoint
    %    showImg(img1,img2,"edge detection result");
    %end

    % feature extraction and matching
    points1 = detectSURFFeatures(img1,"MetricThreshold",500,"NumOctaves",3);
    points2 = detectSURFFeatures(img2,"MetricThreshold",500,"NumOctaves",3);
    
    [features1, validPoints1] = extractFeatures(img1, points1);
    [features2, validPoints2] = extractFeatures(img2, points2);
    
    indexPairs = matchFeatures(features1, features2);
    %size(indexPairs)
    
    matchedPoints1 = validPoints1(indexPairs(:, 1));
    matchedPoints2 = validPoints2(indexPairs(:, 2));

    % fundamental matrix
    matchedPoints1 = matchedPoints1.Location;
    matchedPoints2 = matchedPoints2.Location;

    % matched point visualization
    if visualizeMatchedPoint
        fig = figure;
        showMatchedFeatures(img1, img2, matchedPoints1, matchedPoints2, 'montage');
        title('Matched SURF features');
        waitfor(fig);
    end
    
    [tform,~,status] = estgeotform2d(matchedPoints1,matchedPoints2,"similarity","MaxNumTrials",5000); %<---help hint

    outputView = imref2d(size(img1));
    corrected_img = imwarp(original_imgs{1},tform,"OutputView",outputView);
 
    imgs = {corrected_img,original_imgs{2}};
    
    if status == 0 && tform.A(3,3) >= 0.8
        matched = true;
    else
        matched = false;
    end

    highlights = highlight(corrected_img, original_imgs{2});
end


function Ieval = edge_detection(Igray)
    I = im2double(Igray);

    Gx = [-1 1];
    Gy = Gx';
    Ix = conv2(I,Gx,'same');
    Iy = conv2(I,Gy,'same');

    edgeFIS = mamfis('Name','edgeDetection');

    edgeFIS = addInput(edgeFIS,[-1 1],'Name','Ix');
    edgeFIS = addInput(edgeFIS,[-1 1],'Name','Iy');

    sx = 0.1;
    sy = 0.1;
    edgeFIS = addMF(edgeFIS,'Ix','gaussmf',[sx 0],'Name','zero');
    edgeFIS = addMF(edgeFIS,'Iy','gaussmf',[sy 0],'Name','zero');

    edgeFIS = addOutput(edgeFIS,[0 1],'Name','Iout');

    wa = 0.1;
    wb = 1;
    wc = 1;
    ba = 0;
    bb = 0;
    bc = 0.7;
    edgeFIS = addMF(edgeFIS,'Iout','trimf',[wa wb wc],'Name','white');
    edgeFIS = addMF(edgeFIS,'Iout','trimf',[ba bb bc],'Name','black');

    r1 = "If Ix is zero and Iy is zero then Iout is white";
    r2 = "If Ix is not zero or Iy is not zero then Iout is black";
    edgeFIS = addRule(edgeFIS,[r1 r2]);
    edgeFIS.Rules

    Ieval = zeros(size(I));
    for ii = 1:size(I,1)
        Ieval(ii,:) = evalfis(edgeFIS,[(Ix(ii,:));(Iy(ii,:))]');
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

    threshold = 150;
    bmask = diff > threshold; % binar mask

    hl = cat(3, ones(size(bmask)), ones(size(bmask)), zeros(size(bmask))).*bmask;
end

function [img1,img2] = preprocessing(img1,img2)
    % convert to gray image
    img1 = rgb2gray(img1);
    img2 = rgb2gray(img2);

    % histogram equalization
    img1 = histeq(img1);
    img2 = histeq(img2);

    % histogram match
    img2 = imhistmatch(img2, img1);
end