% 脚本：测试 two_image_analysis 函数

% 选择包含两张图片的文件夹
folder = uigetdir();
if folder == 0
    error('你没有选择任何文件夹');
end

% 获取前两张图片
imageFiles = dir(fullfile(folder, '*.jpg'));
if numel(imageFiles) < 2
    error('该文件夹下至少需要 2 张 .jpg 图片');
end

% 读取两张图片
img1 = imread(fullfile(folder, imageFiles(1).name));
img2 = imread(fullfile(folder, imageFiles(2).name));

% 调用你的函数
[matched, imgs, highlights] = two_image_analysis({img1, img2});

% 显示结果
if matched
    figure;
    imshowpair(imgs{1}, imgs{2}, 'montage');
    title('配准后图像对比');

    figure;
    imshow(highlights);
    title('高亮区域');
else
    disp('图像匹配失败。');
end
