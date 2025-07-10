% 脚本：测试 multiple_image_analysis 函数

% 选择包含多张图片的文件夹
folder = uigetdir();
if folder == 0
    error('你没有选择任何文件夹');
end

% 获取所有 .jpg 图像文件
imageFiles = dir(fullfile(folder, '*.jpg'));
if numel(imageFiles) < 2
    error('至少需要两张图片');
end

% 按文件名自然排序（例如按年份顺序）
[~, idx] = sort_nat({imageFiles.name});
imageFiles = imageFiles(idx);

function [sorted, idx] = sort_nat(c)
    % 自然排序字符串 cell 数组
    [~, idx] = sort_nat_internal(c);
    sorted = c(idx);
end

function [sorted, ndx, dbg] = sort_nat_internal(c,mode)
    
    [sorted, ndx] = sort(c);
    dbg = {};
end

% 读取图像
imgs = cell(1, numel(imageFiles));
for i = 1:numel(imageFiles)
    imgs{i} = imread(fullfile(folder, imageFiles(i).name));
end

% 调用你的函数
resultImgs = multiple_image_analysis(imgs);

length(resultImgs);

% % 显示 TimeLapse 播放
disp('显示 Time Lapse...');
figure;
for i = 1:numel(resultImgs)
   imshow(resultImgs{i});
   title(['Frame ', num2str(i)]);
   pause(1.5);
end
% 
% % 显示 Difference Highlight 效果
% disp('显示 Difference Highlight（叠加）...');
% figure;
% hold on;
% for i = 1:numel(resultImgs)
%     img = im2double(resultImgs{i});
%     h = imshow(img);
%     set(h, 'AlphaData', i / numel(resultImgs));  % 随图片渐变叠加
%     pause(1.5);
% end
% hold off;
