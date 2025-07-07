function [trafo, status] = matching_loop(img1, img2, doVisual)

    % global match
    [trafo, status, ~] = roi_match(img1, img2, [], 50, doVisual);
    
    if status == 0 && abs(trafo.Scale-1) < 0.1
        fprintf("Global matching succeeded.\n");
        return;
    end

    % 4-block matching
    bestMatch = block_matches(img1,img2,2,100,doVisual);
    if bestMatch("num") > 0 && abs(bestMatch("scale")-1) < 0.1
        trafo = bestMatch("trafo");
        status = 0;
        fprintf("Matched using 4-block ROI #%d with %d matches (best)\n", bestMatch("index"), bestMatch("num"));
        return;
    end

    % 9-block matching
    bestMatch = block_matches(img1,img2,3,100,doVisual);
    if bestMatch("num") > 0 && abs(bestMatch("scale")-1) < 0.1
       trafo = bestMatch("trafo");
       status = 0;
       fprintf("Matched using 9-block ROI #%d with %d matches (best)\n", bestMatch("index"), bestMatch("num"));
       return;
    end

    % all fail
    fprintf("both 4- and 9-block Matching failed.\n");
    trafo = NaN;
    status = -1;
end

function bestMatch = block_matches(img1, img2, n, matchThreshold, doVisual)
    if all(size(img1) ~= size(img2))
        error("matching imgs with different size");
    end

    % Divided into 4 blocks matching
    rois = split(img1,n);
    
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

    for i = 1:n^2
        roi = rois(i,:);
        [trafo, status, num] = roi_match(img1, img2, roi, matchThreshold, doVisual);
        if status == 0 
            if num > numMatch("num")
                numMatch("num") = num;
                numMatch("trafo") = trafo;
                numMatch("index") = i;
                numMatch("scale") = trafo.Scale;
            end
            if abs(trafo.Scale - 1) < abs(unscaledMatch("scale") - 1)
                unscaledMatch("num") = num;
                unscaledMatch("trafo") = trafo;
                unscaledMatch("index") = i;
                unscaledMatch("scale") = trafo.Scale;
            end
        end
    end

    % determine best match
    if abs(unscaledMatch("scale") - 1) <= abs(numMatch("scale") - 1)
        bestMatch = unscaledMatch;
    else
        bestMatch = numMatch;
    end

end

function [trafo,status,numMatched] = roi_match(img1, img2, roi, matchThreshold, doVisual)
    % roi = [] stands for full map detection

    % feature extraction
    if isempty(roi)
       points1 = detectSURFFeatures(img1, "MetricThreshold",500,"NumOctaves",4,'NumScaleLevels',6);
       points2 = detectSURFFeatures(img2, "MetricThreshold",500,"NumOctaves",4,'NumScaleLevels',6);
    else
       points1 = detectSURFFeatures(img1, "MetricThreshold",500,"NumOctaves",4,'NumScaleLevels',6, "ROI", roi);
       points2 = detectSURFFeatures(img2, "MetricThreshold",500,"NumOctaves",4,'NumScaleLevels',6, "ROI", roi);
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
        trafo = NaN;
        status = -1;%status: Estimated status of the transform, 0 = success, -1 = failure
        return;
    end

    [trafo, ~, status] = estgeotform2d(matchedPoints1, matchedPoints2, ...
        'similar', 'Confidence', 90, 'MaxNumTrials', 2000, 'MaxDistance', 10);%'similar'kann change 'affine' have a try

    if doVisual
        fig = figure;
        showMatchedFeatures(img1, img2, matchedPoints1, matchedPoints2, 'montage');
        title('Matched features');
        waitfor(fig);
        disp("Transformation matrix (tform.T):");
        disp(trafo.T);
    end
    
end

function blocks = split(img, n)

    [H, W, ~] = size(img);
    h_step = floor(H / n);
    w_step = floor(W / n);

    blocks = zeros(n^2, 4);  % [left, top, width, height]
    idx = 1;

    for row = 0:n-1
        for col = 0:n-1
            top    = row * h_step + 1;
            height = h_step;
            left   = col * w_step + 1;
            width  = w_step;

            % avoid overflow
            if row == n-1
                height = H - top + 1;
            end
            if col == n-1
                width = W - left + 1;
            end

            blocks(idx, :) = [left, top, width, height];
            idx = idx + 1;
        end
    end
end