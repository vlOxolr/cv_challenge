function [trafo, status] = matching_ROI(img1, img2, visualizeMatchedPoint, algorithm)

    % global match
    [trafo, status, ~] = try_match_once(img1, img2, algorithm, visualizeMatchedPoint,[],50);
    
    if status == 0
        fprintf("Global matching succeeded.\n");
        return;
    end

    % Divided into 4 blocks matching
    [h, w] = size(img1);
    roiList4 = [
        1, 1, round(w/2), round(h/2);
        round(w/2)+1, 1, w - round(w/2), round(h/2);
        1, round(h/2)+1, round(w/2), h - round(h/2);
        round(w/2)+1, round(h/2)+1, w - round(w/2), h - round(h/2)
    ];

    bestNumMatches = 0;
    bestTrafo = [];
    bestRoiIndex = -1;

    for i = 1:4
      roi = roiList4(i,:);
      [t, s, n] = try_match_once(img1, img2, algorithm, false, roi,100);
      if s == 0 && n > bestNumMatches
          bestNumMatches = n;
          bestTrafo = t;
          bestRoiIndex = i;
      end
    end
   
   if bestNumMatches > 0
      trafo = bestTrafo;
      status = 0;
      fprintf("Matched using 4-block ROI #%d with %d matches (best)\n", bestRoiIndex, bestNumMatches);
      if visualizeMatchedPoint
         roi = roiList4(bestRoiIndex,:);
         try_match_once(img1, img2, algorithm, true, roi,100);
      end
      return;
   end


    % Divided into 9 blocks matching
    stepW = round(w/3);
    stepH = round(h/3);
    roiList9 = [];
    for i = 0:2
        for j = 0:2
            roiList9 = [roiList9; 1 + i*stepW, 1 + j*stepH, stepW, stepH];
        end
    end

    bestNumMatches = 0;
    bestTrafo = [];
    bestRoiIndex = -1;

    for i = 1:9
       roi = roiList9(i,:);
       [t, s, n] = try_match_once(img1, img2, algorithm, false, roi,100);
       if s == 0 && n > bestNumMatches
          bestNumMatches = n;
          bestTrafo = t;
          bestRoiIndex = i;
       end
    end

    if bestNumMatches > 0
       trafo = bestTrafo;
       status = 0;
       fprintf("Matched using 9-block ROI #%d with %d matches (best)\n", bestRoiIndex, bestNumMatches);
       if visualizeMatchedPoint
         roi = roiList9(bestRoiIndex,:);
         try_match_once(img1, img2, algorithm, true, roi,100);
       end
       return;
    end


    % all fail
    trafo = [];
    status = -1;
end


function [trafo,status,numMatched] = try_match_once(img1, img2, algorithm, visualize, roi, matchThreshold)
    %  % feature extraction
    if algorithm == "surf"
        if isempty(roi)
    % No ROI, just full map detection
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
    numMatched = size(matchedPoints1,1);
    %numMAtched:Points for successful matches
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