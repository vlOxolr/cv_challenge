clear;clc;
addpath("./methods")

% base function
function imgs = read2Img(pth1,pth2)
    
    img1 = imread(pth1);
    img2 = imread(pth2);
    
    imgs{1} = img1;
    imgs{2} = img2;
end

function imgs = readmImg(path)
    image_files = dir(fullfile(path, '*.jpg'));

    imgs = cell(1, length(image_files)); % Initialize cell array for images
    for i = 1:length(image_files)
        file_name = image_files(i).name;
        full_path = fullfile(path, file_name);
        imgs{i} = imread(full_path);
    end
end

function show2Img(imgs,highlights)
    img1 = imgs{1};
    img2 = imgs{2};
    
    subplot(1,3,1);
    imshow(img1);
    title('Image 1');
    
    subplot(1,3,2);
    imshow(img2);
    title('Image 2');

    subplot(1,3,3);
    imshow(highlights);
    title('highlights');
end

function showmImg(imgs)
    n = length(imgs);
    
    for i = 1:n
        subplot(1,n,i);
        imshow(imgs{i});
        title(append('Image ',string(i)));
    end
end

%% two image part
% given datasets
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
%pth1 = "./datasets/givenDatasets/Frauenkirche/2012_08.jpg";
%pth2 = "./datasets/givenDatasets/Frauenkirche/2021_06.jpg";
% ok!
pth1 = "./datasets/givenDatasets/Frauenkirche/2012_08.jpg";
pth2 = "./datasets/givenDatasets/Frauenkirche/2019_06.jpg";

% problem solved by decreasing MetricThreshold
% ok!
%pth1 = "./datasets/givenDatasets/Kuwait/2_2015.jpg";
%pth2 = "./datasets/givenDatasets/Kuwait/7_2016.jpg";

% ok!
%pth1 = "./datasets/givenDatasets/Wiesn/7_2015.jpg";
%pth2 = "./datasets/givenDatasets/Wiesn/3_2020.jpg";

% user datasets
% ok!
%pth1 = "./datasets/userDatasets/Hangzhou/12_1985.jpg";
%pth2 = "./datasets/userDatasets/Hangzhou/12_2015.jpg";

original_imgs = read2Img(pth1,pth2);
[matched,imgs,highlights] = two_image_analysis(original_imgs,"visualizeMatchedPoint",true);
if matched
    disp("images were matched.");
    show2Img(imgs,highlights);
else
    disp("images were not matched.");
    show2Img(imgs,highlights);
end

%% multiple image part
% 0/8
path = "./datasets/givenDatasets/Brazilian Rainforest/";
% 11/11
path = "./datasets/givenDatasets/Columbia Glacier/";
% 8/8
path = "./datasets/givenDatasets/Dubai/";
% 7/10
path = "./datasets/givenDatasets/Frauenkirche/";
% 7/9
path = "./datasets/givenDatasets/Kuwait/";
% 6/8
path = "./datasets/givenDatasets/Wiesn/";

imgs = readmImg(path);
imgs = multiple_image_analysis(imgs);
showmImg(imgs);

%% test part
% edge detection
original_imgs = readImg(pth1,pth2);
edges = edge_detection(original_imgs);
