clear;clc;
%imgA = imread('E:\TUM课程\CV\cv_challenge\datasets\givenDatasets\testColumbia Glacier\12_2012.jpg');
%imgB = imread('E:\TUM课程\CV\cv_challenge\datasets\givenDatasets\testColumbia Glacier\12_2000.jpg');%reference

%result_path = './results/test_alignment/';
%Registration(imgA, imgB, result_path);


path = "E:/TUM课程/CV/cv_challenge/datasets/givenDatasets/Frauenkirche/";
imgs = readmImg(path);

imgs = multiple_image_analysis(imgs,"algorithm","surf");
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

function imgs = readmImg(path)
    image_files = dir(fullfile(path, '*.jpg'));

    % Parse dates from filenames
    dates = zeros(length(image_files), 1);
    for i = 1:length(image_files)
        name = image_files(i).name;
        parts = split(name, {'_', '.'});  % YYYY MM.jpg → {'2020','11','jpg'}
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


function showmImg(imgs)
    n = length(imgs);
    
    for i = 1:n
        subplot(1,n,i);
        imshow(imgs{i});
        title(append('Image ',string(i)));
    end
end