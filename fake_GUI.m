clear;clc;
addpath("./methods")

original_imgs = readImg();
imgs = two_image_analysis(original_imgs);
showImg(imgs);

function original_imgs = readImg()
    img1 = imread("./datasets/givenDatasets/Dubai/12_1990.jpg");
    img2 = imread("./datasets/givenDatasets/Dubai/12_2003.jpg");
    
    % high singular value sometimes -> big transition
    %img1 = imread("./datasets/givenDatasets/Frauenkirche/2012_08.jpg");
    %img2 = imread("./datasets/givenDatasets/Frauenkirche/2016_07.jpg");
    
    % problem!!!
    %img1 = imread("./datasets/givenDatasets/Kuwait/2_2015.jpg");
    %img2 = imread("./datasets/givenDatasets/Kuwait/7_2016.jpg");
    
    % problem!!!
    %img1 = imread("./datasets/givenDatasets/Brazilian Rainforest/12_1985.jpg");
    %img2 = imread("./datasets/givenDatasets/Brazilian Rainforest/12_2005.jpg");

    %img1 = imread("./datasets/userDatasets/Hangzhou/12_1985.jpg");
    %img2 = imread("./datasets/userDatasets/Hangzhou/12_2005.jpg");
    
    original_imgs{1} = img1;
    original_imgs{2} = img2;
end

function showImg(imgs)
    img1 = imgs{1};
    img2 = imgs{2};
    
    subplot(1,2,1);
    imshow(img1);
    title('Image 1');
    
    subplot(1,2,2);
    imshow(img2);
    title('Image 2');
    
end