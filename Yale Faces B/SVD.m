% 创建图像数据存储
imds = imageDatastore('D:\learngit\Datadriven_homework\homework2\yalefaces_cropped\CroppedYale', 'IncludeSubfolders', true, 'FileExtensions', '.pgm');

% 读取所有图像
cropped_images = readall(imds);

% 确保将每个图像转换为双精度数组
% cropped_images是一个cell array，需转换为3D数组
num_images = numel(cropped_images);
image_size = size(cropped_images{1}); % 假设所有图像大小相同

% 初始化3D数组
images_array = zeros(image_size(1), image_size(2), num_images);

% 将cell array转换为3D数组
for i = 1:num_images
    images_array(:, :, i) = im2double(cropped_images{i}); % 将图像转换为双精度
end

% 将每个图像重塑为列向量
reshaped_images = reshape(images_array, [], num_images)'; % 转置

% 执行SVD
[U, S, V] = svd(reshaped_images, 'econ');

% 显示U、Σ和V矩阵
%disp('U矩阵:');
%disp(U);
size(U)
%disp('Σ矩阵（奇异值）:');
%disp(S);
size(S)
%disp('V矩阵:');
%disp(V);
size(V)

% 奇异值谱
singular_values = diag(S);
plot(singular_values, 'o');
title('奇异值谱');
xlabel('奇异值索引');
ylabel('奇异值大小');

% 确定面部空间的秩r
% 一种方法是找到奇异值开始显著下降的点
% 另一种方法是计算累积能量直到达到某个阈值，例如95%
cumulative_energy = cumsum(singular_values) / sum(singular_values);
r = find(cumulative_energy >= 0.95, 1, 'first');
disp(['面部空间的秩r是：', num2str(r)]);

