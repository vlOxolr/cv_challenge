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

% % 读取两张图片
% img1 = imread(fullfile(folder, imageFiles(1).name));
% img2 = imread(fullfile(folder, imageFiles(2).name));

% 图片文件路径
pic1_path = fullfile(folder, imageFiles(1).name);  % 第一张图片
pic2_path = fullfile(folder, imageFiles(2).name);  % 第二张图片

%%
% 配置参数
curtain_html_dir = 'curtain';  % HTML文件存放目录
select_data_name = 'data';    % 数据集名称
current_image_names = {imageFiles(1).name, imageFiles(2).name};  % 根据截图中的图片名称

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
    
    % 创建img文件夹
    img_folder = fullfile(dataset_html_dir, "img");
    if ~exist(img_folder, 'dir')
        mkdir(img_folder);
    end
    
    disp(['图片文件夹路径: ', img_folder]);
    disp(['源图片1路径: ', pic1_path]);
    disp(['源图片2路径: ', pic2_path]);
    
    % 复制图片文件
    if exist(pic1_path, 'file') && exist(pic2_path, 'file')
        copyfile(pic1_path, fullfile(img_folder, "pic_1.jpg"));
        copyfile(pic2_path, fullfile(img_folder, "pic_2.jpg"));
        disp('图片复制成功！');
    else
        error('图片文件不存在，请检查文件路径');
    end
end

% 创建简单窗口
fig = uifigure('Name', '窗帘效果', 'Position', [100 100 850 500]);
% 创建HTML组件
HTML_curtain = uihtml(fig);
HTML_curtain.Position = [20 20 810 460];
HTML_curtain.HTMLSource = fullfile(dataset_html_dir, 'sliding_curtain.html');
disp('窗帘效果窗口创建完成！');