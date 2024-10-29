% 设置数据集路径
maleFolder = 'D:\learngit\Datadriven_homework\homework2\yalefaces_cropped\genderCroppedYale\male'; % 男性文件夹
femaleFolder = 'D:\learngit\Datadriven_homework\homework2\yalefaces_cropped\genderCroppedYale\female'; % 女性文件夹

% 获取男性和女性图像文件，包括子文件夹
maleFiles = dir(fullfile(maleFolder, '**', '*.pgm'));
femaleFiles = dir(fullfile(femaleFolder, '**', '*.pgm'));

% 初始化特征矩阵和标签
features = [];
labels = []; % 0 表示男性，1 表示女性

% 确定有效的特征层名
layerNames = net.Layers;
disp(layerNames);
featureLayer = 'fc1000'; % 更新为存在的层名

% 提取男性特征
for i = 1:length(maleFiles)
    try
        img = imread(fullfile(maleFiles(i).folder, maleFiles(i).name));
        img = imresize(img, [227 227]); % 调整大小以适应 CNN 输入
        
        % 将灰度图转换为 RGB
        if size(img, 3) == 1
            img = cat(3, img, img, img); % 转换为 RGB
        end
        
        imgFeatures = activations(net, img, featureLayer);
        features = [features; imgFeatures(:)']; % 将特征展开并添加到矩阵中
        labels = [labels; 0]; % 添加标签
    catch ME
        warning('无法读取文件: %s, 错误信息: %s', maleFiles(i).name, ME.message);
    end
end

% 提取女性特征
for i = 1:length(femaleFiles)
    try
        img = imread(fullfile(femaleFiles(i).folder, femaleFiles(i).name));
        img = imresize(img, [227 227]);
        
        % 将灰度图转换为 RGB
        if size(img, 3) == 1
            img = cat(3, img, img, img); % 转换为 RGB
        end
        
        imgFeatures = activations(net, img, featureLayer);
        features = [features; imgFeatures(:)'];
        labels = [labels; 1]; % 添加标签
    catch ME
        warning('无法读取文件: %s, 错误信息: %s', femaleFiles(i).name, ME.message);
    end
end


% 确保 labels 是一个数值向量
labels = labels(:); % 转换为列向量，确保是向量类型

% 检查样本数量
fprintf('男性样本数量: %d\n', length(maleFiles));
fprintf('女性样本数量: %d\n', length(femaleFiles));

% 确保特征矩阵不为空
if isempty(features)
    error('特征矩阵为空，检查图像读取和特征提取是否成功。');
end

% 将特征矩阵和标签分为训练集和测试集
cv = cvpartition(labels, 'HoldOut', 0.2); % 80% 训练集，20% 测试集
idx = cv.test;

% 训练集和测试集
featuresTrain = features(~idx, :);
labelsTrain = labels(~idx);
featuresTest = features(idx, :);
labelsTest = labels(idx);

% 确保训练和测试集都有样本
if isempty(featuresTrain) || isempty(featuresTest)
    error('训练集或测试集为空，检查样本数量是否足够。');
end

% 使用 SVM 分类器训练模型
SVMModel = fitcecoc(featuresTrain, labelsTrain);

% 在测试集上进行预测
predictedLabels = predict(SVMModel, featuresTest);

% 评估分类器性能
accuracy = sum(predictedLabels == labelsTest) / length(labelsTest);
fprintf('分类器准确率: %.2f%%\n', accuracy * 100);
