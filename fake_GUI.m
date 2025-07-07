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

    % Parse dates from filenames
    dates = zeros(length(image_files), 1);
    for i = 1:length(image_files)
        name = image_files(i).name;
        parts = split(name, {'_', '.'});  % YYYY_ MM.jpg → {'2020','11','jpg'}
        year  = str2double(parts{1});
        month = str2double(parts{2});
        dates(i) = year * 100 + month;  % Use YYYYMM as sortable number
    end

    % Sort by date
    [~, idx] = sort(dates);
    image_files = image_files(idx);

    % Load images
    imgs = cell(1, length(image_files));
    for i = 1:length(image_files)
        full_path = fullfile(path, image_files(i).name);
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
        subplot(3,4,i);
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
pth1 = "./datasets/givenDatasets/Columbia Glacier/12_2010.jpg";
pth2 = "./datasets/givenDatasets/Columbia Glacier/12_2016.jpg";

% ok!
%pth1 = "./datasets/givenDatasets/Dubai/12_1990.jpg";
%pth2 = "./datasets/givenDatasets/Dubai/12_2003.jpg";

% high singular value sometimes -> big transition
% could not find enough inliner error (2012_08,2021_06)
%pth1 = "./datasets/givenDatasets/Frauenkirche/2012_08.jpg";
%pth2 = "./datasets/givenDatasets/Frauenkirche/2021_06.jpg";
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

% user datasets
% ok!
%pth1 = "./datasets/userDatasets/Hangzhou/12_1985.jpg";
%pth2 = "./datasets/userDatasets/Hangzhou/12_2015.jpg";

original_imgs = read2Img(pth1,pth2);
[matched,imgs,highlights] = two_image_analysis(original_imgs,"visualizeMatchedPoint",false);
if matched
    disp("images were matched.");
    show2Img(imgs,highlights);
else
    disp("images were not matched.");
end

%% multiple image part
clc;clear;

% 0/8
%path = "./datasets/givenDatasets/Brazilian Rainforest/";
% 11/11
%path = "./datasets/givenDatasets/Columbia Glacier/";
% 8/8
%path = "./datasets/givenDatasets/Dubai/";
% 8/10 (sometimes 9/10)
path = "./datasets/givenDatasets/Frauenkirche/";
% 9/9
%path = "./datasets/givenDatasets/Kuwait/";
% 8/8
%path = "./datasets/givenDatasets/Wiesn/";

% user Datasets
% 5/8 (sometimes 8/8)
%path = "./datasets/userDatasets/Guangzhou/";
% 8/8
%path = "./datasets/userDatasets/Hangzhou/";
% 5/8
%path = "./datasets/userDatasets/Hetian/";
% 5/8
%path = "./datasets/userDatasets/Wuhan/";

imgs = readmImg(path);
imgs = multiple_image_analysis(imgs);
showmImg(imgs);
