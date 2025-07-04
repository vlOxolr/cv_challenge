function [trafo,status] = SURFmatching(img1,img2,visualizeMatchedPoint)

    % feature extraction and matching
    points1 = detectSURFFeatures(img1,"MetricThreshold",500,"NumOctaves",4,'NumScaleLevels', 6);
    points2 = detectSURFFeatures(img2,"MetricThreshold",500,"NumOctaves",4,'NumScaleLevels', 6);
    
    [features1, validPoints1] = extractFeatures(img1, points1);
    [features2, validPoints2] = extractFeatures(img2, points2);
    
    indexPairs = matchFeatures(features1,features2,'Method','Exhaustive','Unique',true,'MatchThreshold',100);
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
    
    [trafo,~,status] = estgeotform2d(matchedPoints1,matchedPoints2,...
            'similar','Confidence',90,'MaxNumTrials',2000,'MaxDistance',10); %<---help hint
    disp("Transformation matrix (tform.T):");
    disp(trafo.T);
end