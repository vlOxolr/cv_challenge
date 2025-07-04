function [trafo,status] = matching(img1,img2,visualizeMatchedPoint,algorithm)

    if algorithm == "surf"
        % feature extraction and matching
        points1 = detectSURFFeatures(img1,"MetricThreshold",500,"NumOctaves",3);
        points2 = detectSURFFeatures(img2,"MetricThreshold",500,"NumOctaves",3);
    elseif algorithm == "harris"
        points1 = detectHarrisFeatures(img1);
        points2 = detectHarrisFeatures(img2);
    elseif algorithm == "mineigen"
        points1 = detectMinEigenFeatures(img1);
        points2 = detectMinEigenFeatures(img2);
    elseif algorithm == "brisk"
        points1 = detectMinEigenFeatures(img1);
        points2 = detectMinEigenFeatures(img2);       
    elseif algorithm == "fast"
        points1 = detectFASTFeatures(img1);
        points2 = detectFASTFeatures(img2);
    elseif algorithm == "orb"
        points1 = detectORBFeatures(img1);
        points2 = detectORBFeatures(img2);
    elseif algorithm == "mser"
        points1 = detectMSERFeatures(img1);
        points2 = detectMSERFeatures(img2);
    elseif algorithm == "kaze"
        points1 = detectKAZEFeatures(img1,"Diffusion","edge");
        points2 = detectKAZEFeatures(img2,"Diffusion","edge");
    end
    
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
    
    [trafo,~,status] = estgeotform2d(matchedPoints1,matchedPoints2,"similarity","MaxNumTrials",5000); %<---help hint
end