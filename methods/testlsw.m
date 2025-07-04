clear;clc;
%imgA = imread('E:\TUM课程\CV\cv_challenge\datasets\givenDatasets\testColumbia Glacier\12_2012.jpg');
%imgB = imread('E:\TUM课程\CV\cv_challenge\datasets\givenDatasets\testColumbia Glacier\12_2000.jpg');%reference

%result_path = './results/test_alignment/';
%Registration(imgA, imgB, result_path);


path = "E:/TUM课程/CV/cv_challenge/datasets/givenDatasets/Dubai/";
imgs = readmImg(path);
imgs = multiple_image_analysis(imgs);
showmImg(imgs);

output_folder = './results/multiple_image_output';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

for i = 1:numel(imgs)
    filename = sprintf('aligned_img_%02d.png', i); 
    imwrite(imgs{i}, fullfile(output_folder, filename));
end

%disp("✅ 所有图像已保存至: " + output_folder);

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