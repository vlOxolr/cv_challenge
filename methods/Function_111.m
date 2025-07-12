clc;clear;close all
%%
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

% 图片文件路径
pic1_path = fullfile(folder, imageFiles(1).name); % 第一张图片
pic2_path = fullfile(folder, imageFiles(2).name); % 第二张图片

% 读取原始图像
img1 = imread(pic1_path);
img2 = imread(pic2_path);

disp('原始图像读取成功!');
disp(['图片1尺寸: ', num2str(size(img1))]);
disp(['图片2尺寸: ', num2str(size(img2))]);

%%
% 图像配准处理
disp('开始进行图像配准...');
try
    % 调用你的函数进行图像配准
    [matched, imgs, highlights] = two_image_analysis({img1, img2});
    
    disp('图像配准完成!');
    disp(['配准结果: matched = ', num2str(matched)]);
    disp(['配准后图像1尺寸: ', num2str(size(imgs{1}))]);
    disp(['配准后图像2尺寸: ', num2str(size(imgs{2}))]);
    
    % 使用配准后的图像
    processed_img1 = imgs{1};
    processed_img2 = imgs{2};
    
catch ME
    warning('图像配准失败，将使用原始图像: %s', ME.message);
    % 如果配准失败，使用原始图像
    processed_img1 = img1;
    processed_img2 = img2;
end

%%
% 配置参数
curtain_html_dir = 'curtain'; % HTML文件存放目录

% 使用文件夹名称作为数据集名称,确保每个文件夹有独立的HTML目录
[~, folder_name] = fileparts(folder);
select_data_name = [folder_name, '_registration']; % 添加标识表示这是配准对比
select_data_name = regexprep(select_data_name, '[^\w]', '_');

% 设置路径
dataset_html_dir = fullfile(curtain_html_dir, select_data_name);
disp(['拷贝目标路径: ', dataset_html_dir]);

% 检查并创建目录
if exist(dataset_html_dir, 'dir') ~= 7
    % 从curtain目录复制文件
    if exist('curtain', 'dir') == 7
        copyfile('curtain', dataset_html_dir);
    else
        mkdir(dataset_html_dir);
    end
end

% 创建img文件夹
img_folder = fullfile(dataset_html_dir, "img");
if ~exist(img_folder, 'dir')
    mkdir(img_folder);
end

disp(['图片文件夹路径: ', img_folder]);

%%
% 保存配准后的两张图像用于窗帘效果展示
try
    % 保存配准后的第一张图像作为pic_1.jpg（窗帘左侧）
    imwrite(processed_img1, fullfile(img_folder, "pic_1.jpg"));
    
    % 保存配准后的第二张图像作为pic_2.jpg（窗帘右侧）
    imwrite(processed_img2, fullfile(img_folder, "pic_2.jpg"));
    
    disp('配准后图像保存成功!');
    disp(['窗帘左侧 (pic_1.jpg): 配准后的图像1 (imgs{1})']);
    disp(['窗帘右侧 (pic_2.jpg): 配准后的图像2 (imgs{2})']);
    
catch ME
    error('保存配准后图像失败: %s', ME.message);
end

%%
% 创建窗帘效果窗口展示配准后的两张图像
fig = uifigure('Name', ['配准后图像对比 - ', folder_name], 'Position', [100 100 850 500]);

% 创建HTML组件
HTML_curtain = uihtml(fig);
HTML_curtain.Position = [20 20 810 460];
HTML_curtain.HTMLSource = fullfile(dataset_html_dir, 'sliding_curtain.html');

disp('窗帘效果窗口创建完成!');
disp(['当前显示文件夹: ', folder]);
disp(['HTML文件路径: ', fullfile(dataset_html_dir, 'sliding_curtain.html')]);

% 显示最终状态
if exist('matched', 'var')
    if matched
        disp('=== 处理完成 ===');
        disp('窗帘效果展示: 左侧为配准后图像1 (imgs{1})，右侧为配准后图像2 (imgs{2})');
        disp('拖动窗帘可以看到配准后的两张图像对比');
    else
        disp('=== 处理完成 ===');
        disp('图像配准失败，窗帘效果展示原始图像');
    end
else
    disp('=== 处理完成 ===');
    disp('未进行图像配准，窗帘效果展示原始图像');
end