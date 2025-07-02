clear;clc;
addpath("./methods")

%% given datasets
% Brazilian Rainforest
% problem!!!
%pth1 = "./datasets/givenDatasets/Brazilian Rainforest/12_1990.jpg";
%pth2 = "./datasets/givenDatasets/Brazilian Rainforest/12_2005.jpg";
% ok!
%pth1 = "./datasets/givenDatasets/Brazilian Rainforest/12_1995.jpg";
%pth2 = "./datasets/givenDatasets/Brazilian Rainforest/12_1985.jpg";

% ok!
%pth1 = "./datasets/givenDatasets/Columbia Glacier/12_2010.jpg";
%pth2 = "./datasets/givenDatasets/Columbia Glacier/12_2016.jpg";

% ok!
%pth1 = "./datasets/givenDatasets/Dubai/12_1990.jpg";
%pth2 = "./datasets/givenDatasets/Dubai/12_2003.jpg";

% high singular value sometimes -> big transition
% could not find enough inliner error (2012_08,2021_06)
pth1 = "./datasets/givenDatasets/Frauenkirche/2012_08.jpg";
pth2 = "./datasets/givenDatasets/Frauenkirche/2021_06.jpg";
% ok!
%pth1 = "./datasets/givenDatasets/Frauenkirche/2012_08.jpg";
%pth2 = "./datasets/givenDatasets/Frauenkirche/2019_06.jpg";

% problem solved by decreasing MetricThreshold
% ok!
%pth1 = "./datasets/givenDatasets/Kuwait/2_2015.jpg";
%pth2 = "./datasets/givenDatasets/Kuwait/7_2016.jpg";

% ok!
%pth1 = "./datasets/givenDatasets/Wiesn/7_2015.jpg";
%pth2 = "./datasets/givenDatasets/Wiesn/3_2020.jpg";

%% user datasets
% ok!
%pth1 = "./datasets/userDatasets/Hangzhou/12_1985.jpg";
%pth2 = "./datasets/userDatasets/Hangzhou/12_2015.jpg";

original_imgs = readImg(pth1,pth2);
[matched,imgs,highlights] = two_image_analysis(original_imgs);
if matched
    disp("images were matched.");
    showImg(imgs);
    %imshow(highlights);
else
    disp("images were not matched.");
end


function original_imgs = readImg(pth1,pth2)
    
    img1 = imread(pth1);
    img2 = imread(pth2);
    
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