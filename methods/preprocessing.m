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