% 加载裁剪图像数据集
imds_cropped = imageDatastore('D:\learngit\Datadriven_homework\homework2\yalefaces_cropped\CroppedYale', 'IncludeSubfolders', true, 'FileExtensions', '.pgm');

% 加载未裁剪图像数据集
imds_uncropped = imageDatastore('D:\learngit\Datadriven_homework\homework2\yalefaces_uncropped\gifyalefaces', 'IncludeSubfolders', true);

% 定义旋转角度
theta_small = rand * 30 - 15; % 小角度，例如 -15 到 15 度
theta_large = rand * 90 - 45; % 大角度，例如 -45 到 45 度

% 旋转图像的函数
function rotated_img = rotate_image(img, theta)
    rotated_img = imrotate(img, theta, 'bilinear', 'crop');
end

% 处理裁剪图像
cropped_images = readall(imds_cropped);
rotated_cropped_images_small = cellfun(@(img) rotate_image(img, theta_small), cropped_images, 'UniformOutput', false);
rotated_cropped_images_large = cellfun(@(img) rotate_image(img, theta_large), cropped_images, 'UniformOutput', false);

% 确保所有旋转后的图像具有相同的尺寸
% 获取第一个图像的尺寸
height = size(rotated_cropped_images_small{1}, 1);
width = size(rotated_cropped_images_small{1}, 2);

% 检查所有图像的尺寸并调整
rotated_cropped_images_small = cellfun(@(img) imresize(img, [height, width]), rotated_cropped_images_small, 'UniformOutput', false);
rotated_cropped_images_large = cellfun(@(img) imresize(img, [height, width]), rotated_cropped_images_large, 'UniformOutput', false);

% 将旋转后的裁剪图像重塑为列向量，确保是双精度格式
num_images_cropped = length(rotated_cropped_images_small);
cropped_images_small_vec = reshape(cell2mat(cellfun(@(img) im2double(img), rotated_cropped_images_small, 'UniformOutput', false)), height * width, num_images_cropped);
cropped_images_large_vec = reshape(cell2mat(cellfun(@(img) im2double(img), rotated_cropped_images_large, 'UniformOutput', false)), height * width, num_images_cropped);

% 对旋转后的裁剪图像执行SVD
[U_small, S_small, V_small] = svd(cropped_images_small_vec, 'econ');
[U_large, S_large, V_large] = svd(cropped_images_large_vec, 'econ');

% 确定SVD的秩
rank_small = sum(diag(S_small) > 1e-6);
rank_large = sum(diag(S_large) > 1e-6);

% 显示秩
disp(['裁剪图像小角度旋转的秩: ', num2str(rank_small)]);
disp(['裁剪图像大角度旋转的秩: ', num2str(rank_large)]);

% 处理未裁剪图像
uncropped_images = readall(imds_uncropped);
rotated_uncropped_images_small = cellfun(@(img) rotate_image(img, theta_small), uncropped_images, 'UniformOutput', false);
rotated_uncropped_images_large = cellfun(@(img) rotate_image(img, theta_large), uncropped_images, 'UniformOutput', false);

% 确保所有旋转后的图像具有相同的尺寸
% 获取第一个未裁剪图像的尺寸（可能与裁剪图像不同）
if ~isempty(rotated_uncropped_images_small)
    height_uncropped = size(rotated_uncropped_images_small{1}, 1);
    width_uncropped = size(rotated_uncropped_images_small{1}, 2);
    
    % 检查所有图像的尺寸并调整
    rotated_uncropped_images_small = cellfun(@(img) imresize(img, [height_uncropped, width_uncropped]), rotated_uncropped_images_small, 'UniformOutput', false);
    rotated_uncropped_images_large = cellfun(@(img) imresize(img, [height_uncropped, width_uncropped]), rotated_uncropped_images_large, 'UniformOutput', false);
    
    % 将旋转后的未裁剪图像重塑为列向量，确保是双精度格式
    num_images_uncropped = length(rotated_uncropped_images_small);
    uncropped_images_small_vec = reshape(cell2mat(cellfun(@(img) im2double(img), rotated_uncropped_images_small, 'UniformOutput', false)), height_uncropped * width_uncropped, num_images_uncropped);
    uncropped_images_large_vec = reshape(cell2mat(cellfun(@(img) im2double(img), rotated_uncropped_images_large, 'UniformOutput', false)), height_uncropped * width_uncropped, num_images_uncropped);

    % 对旋转后的未裁剪图像执行SVD
    [U_uncropped_small, S_uncropped_small, V_uncropped_small] = svd(uncropped_images_small_vec, 'econ');
    [U_uncropped_large, S_uncropped_large, V_uncropped_large] = svd(uncropped_images_large_vec, 'econ');

    % 确定SVD的秩
    rank_uncropped_small = sum(diag(S_uncropped_small) > 1e-6);
    rank_uncropped_large = sum(diag(S_uncropped_large) > 1e-6);

    % 显示秩
    disp(['未裁剪图像小角度旋转的秩: ', num2str(rank_uncropped_small)]);
    disp(['未裁剪图像大角度旋转的秩: ', num2str(rank_uncropped_large)]);
else
    disp('未裁剪图像集为空。');
end
