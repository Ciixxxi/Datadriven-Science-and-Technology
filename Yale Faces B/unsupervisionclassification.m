% 定义包含子文件夹的根文件夹路径
rootFolderPath = 'D:\learngit\Datadriven_homework\homework2\yalefaces_cropped\CroppedYale'; % 替换为你的根文件夹路径

% 检查根文件夹路径是否存在
if ~exist(rootFolderPath, 'dir')
    error('根文件夹路径不存在：%s', rootFolderPath);
end

% 获取根文件夹及其子文件夹中所有.pgm文件的信息
files = dir(fullfile(rootFolderPath, '**', '*.pgm'));

% 检查是否找到了.pgm文件
if isempty(files)
    error('在根文件夹及其子文件夹中没有找到任何.pgm文件：%s', rootFolderPath);
end

% 读取第一个文件来确定图像尺寸
firstImgPath = fullfile(files(1).folder, files(1).name); % 构建完整的文件路径
firstImg = imread(firstImgPath);
[height, width] = size(firstImg);

% 初始化一个数组来存储图像数据
numFiles = numel(files);
X = zeros(height, width, 1, numFiles); % 使用实际的图像尺寸

% 读取每个文件并存储图像数据
for i = 1:numFiles
    imgPath = fullfile(files(i).folder, files(i).name); % 构建完整的文件路径
    img = imread(imgPath);
    
    % 转换图像为灰度（如果它还不是灰度的）
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    
    % 将图像转换为双精度浮点数，并归一化到[0,1]范围
    img = double(img) / 255;
    
    % 将图像数据存储到数组中
    X(:, :, 1, i) = img;
end

% 使用k-means算法对图像数据进行聚类
k = 5; % 假设我们想要找到5个聚类
[idx, C] = kmeans(reshape(X, height * width, numFiles)', k); % 注意这里的转置
fprintf('找到 %d 个聚类\n', k);

% 可视化聚类结果
figure;
for i = 1:k
    subplot(2, ceil(k/2), i);
    clusterIdx = find(idx == i); % 找到属于第 i 个聚类的索引
    clusterImg = zeros(height, width);
    
    if isempty(clusterIdx)
        warning('聚类 %d 没有找到有效的图像索引。', i);
        continue; % 跳过没有图像的聚类
    end
    
    for j = 1:length(clusterIdx)
        % 使用聚类索引直接访问
        fileIndex = clusterIdx(j); % 此时 clusterIdx 直接使用
        if fileIndex <= numFiles
            clusterImg = clusterImg + X(:, :, 1, fileIndex);
        else
            warning('索引 %d 超出范围，跳过。', fileIndex);
        end
    end
    
    clusterImg = clusterImg / length(clusterIdx); % 计算平均图像
    imshow(clusterImg, []);
    title(sprintf('Cluster %d', i));
end
