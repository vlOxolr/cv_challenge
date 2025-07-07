function [trafo, status] = matching_ROI(img1, img2, visualizeMatchedPoint, algorithm)

    % global match
    [trafo, status, ~] = try_once(img1, img2, algorithm, visualizeMatchedPoint,[],50);
    
    if status == 0 && abs(trafo.Scale-1) < 0.1
        fprintf("Global matching succeeded.\n");
        return;
    end

    % Divided into 4 blocks matching
    rois = split(img1,2);
    
    % match with most matching points
    numMatch = containers.Map();
    numMatch("num") = 0;
    numMatch("trafo") = [];
    numMatch("index") = -1;
    numMatch("scale") = -1;

    % match with most matching points
    unscaledMatch = containers.Map();
    unscaledMatch("num") = 0;
    unscaledMatch("trafo") = [];
    unscaledMatch("index") = -1;
    unscaledMatch("scale") = -1;

    %bestNumMatches = 0;
    %bestTrafo = [];
    %bestRoiIndex = -1;

    for i = 1:4
        roi = rois(i,:);
        [t, s, n] = try_once(img1, img2, algorithm, false, roi, 100);
        if s == 0 
            if n > numMatch("num")
                numMatch("num") = n;
                numMatch("trafo") = t;
                numMatch("index") = i;
                numMatch("scale") = t.Scale;
            end
            if abs(t.Scale - 1) < abs(unscaledMatch("scale") - 1)
                unscaledMatch("num") = n;
                unscaledMatch("trafo") = t;
                unscaledMatch("index") = i;
                unscaledMatch("scale") = t.Scale;
            end
        end
    end

    % determine best match
    if abs(unscaledMatch("scale") - 1) <= abs(numMatch("scale") - 1)
        bestMatch = unscaledMatch;
    else
        bestMatch = numMatch;
    end
   
    if bestMatch("num") > 0 && abs(bestMatch("scale")-1) < 0.1
        trafo = bestMatch("trafo");
        status = 0;
        fprintf("Matched using 4-block ROI #%d with %d matches (best)\n", bestMatch("index"), bestMatch("num"));
        return;
    end


    % Divided into 9 blocks matching
    rois = split(img1,3);

    % match with most matching points
    numMatch = containers.Map();
    numMatch("num") = 0;
    numMatch("trafo") = [];
    numMatch("index") = -1;
    numMatch("scale") = -1;

    % match with most matching points
    unscaledMatch = containers.Map();
    unscaledMatch("num") = 0;
    unscaledMatch("trafo") = [];
    unscaledMatch("index") = -1;
    unscaledMatch("scale") = -1;

    for i = 1:9
       roi = rois(i,:);
       [t, s, n] = try_once(img1, img2, algorithm, false, roi, 100);
       if s == 0 
            if n > numMatch("num")
                numMatch("num") = n;
                numMatch("trafo") = t;
                numMatch("index") = i;
                numMatch("scale") = t.Scale;
            end
            if abs(t.Scale - 1) < abs(unscaledMatch("scale") - 1)
                unscaledMatch("num") = n;
                unscaledMatch("trafo") = t;
                unscaledMatch("index") = i;
                unscaledMatch("scale") = t.Scale;
            end
        end
    end
    
    % determine best match
    if abs(unscaledMatch("scale") - 1) <= abs(numMatch("scale") - 1)
        bestMatch = unscaledMatch;
    else
        bestMatch = numMatch;
    end

    if bestMatch("num") > 0 && abs(bestMatch("scale")-1) < 0.1
       trafo = bestMatch("trafo");
       status = 0;
       fprintf("Matched using 9-block ROI #%d with %d matches (best)\n", bestMatch("index"), bestMatch("num"));
       return;
    end

    % all fail
    fprintf("both 4- and 9-block Matching failed.\n");
    trafo = [];
    status = -1;
end

function [trafo,status,numMatched] = try_once(img1, img2, algorithm, visualize, roi, matchThreshold)
    % roi = [] stands for full map detection

    % feature extraction
    if algorithm == "surf"
        if isempty(roi)
           points1 = detectSURFFeatures(img1, "MetricThreshold",500,"NumOctaves",4,'NumScaleLevels',6);
           points2 = detectSURFFeatures(img2, "MetricThreshold",500,"NumOctaves",4,'NumScaleLevels',6);
        else
           [h, w] = size(img1);
           x = roi(1); y = roi(2); width = roi(3); height = roi(4);
           width = min(width, w - x + 1);
           height = min(height, h - y + 1);
           roi = [x, y, width, height];

           points1 = detectSURFFeatures(img1, "MetricThreshold",500,"NumOctaves",4,'NumScaleLevels',6, "ROI", roi);
           points2 = detectSURFFeatures(img2, "MetricThreshold",500,"NumOctaves",4,'NumScaleLevels',6, "ROI", roi);
        end

    end

    [features1, validPoints1] = extractFeatures(img1, points1);
    [features2, validPoints2] = extractFeatures(img2, points2);

    indexPairs = matchFeatures(features1, features2, 'Method','Exhaustive','Unique',true,'MatchThreshold', matchThreshold);
    
    matchedPoints1 = validPoints1(indexPairs(:, 1));
    matchedPoints2 = validPoints2(indexPairs(:, 2));
    
    matchedPoints1 = matchedPoints1.Location;
    matchedPoints2 = matchedPoints2.Location;

    % Points for successful matches
    numMatched = length(matchedPoints1);
    
    if numMatched < 4
        trafo = [];
        status = -1;%status: Estimated status of the transform, 0 = success, -1 = failure
        return;
    end

    if visualize
        fig = figure;
        showMatchedFeatures(img1, img2, matchedPoints1, matchedPoints2, 'montage');
        title('Matched features');
        waitfor(fig);
        %disp("Transformation matrix (tform.T):");
        %disp(trafo.T);
    end

    [trafo, ~, status] = estgeotform2d(matchedPoints1, matchedPoints2, ...
        'similar', 'Confidence', 90, 'MaxNumTrials', 2000, 'MaxDistance', 10);%'similar'kann change 'affine' have a try
end

function blocks = split(img, n)

    [H, W, ~] = size(img);
    h_step = floor(H / n);
    w_step = floor(W / n);

    blocks = zeros(n^2, 4);  % [left, top, right, bottom]
    idx = 1;

    for row = 0:n-1
        for col = 0:n-1
            top    = row * h_step + 1;
            bottom = (row + 1) * h_step;
            left   = col * w_step + 1;
            right  = (col + 1) * w_step;

            % avoid overflow
            if row == n-1
                bottom = H;
            end
            if col == n-1
                right = W;
            end

            blocks(idx, :) = [left, top, right, bottom];
            idx = idx + 1;
        end
    end
end