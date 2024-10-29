% 数据集路径
dataFolder = 'D:\learngit\Datadriven_homework\homework2\yalefaces_cropped\CroppedYale';

% 创建一个 imageDatastore 来读取图片，允许.pgm格式
imds = imageDatastore(dataFolder, 'IncludeSubfolders', true, 'LabelSource', 'foldernames', ...
    'FileExtensions', {'.pgm'}); % 修改为 .pgm格式

% 划分训练集和验证集
[imdsTrain, imdsValidation] = splitEachLabel(imds, 0.8, 'randomize');

% 修改图像预处理函数，将单通道图像转换为三通道，并调整图像大小为 224x224
processImage = @(img)imresize(repmat(img, [1, 1, 3]), [224 224]);

% 创建增强的图像数据存储，并确保所有图像都是224x224
augimdsTrain = augmentedImageDatastore([224 224], imdsTrain, ...
    'DataAugmentation', imageDataAugmenter( ...
        'RandXReflection', true, ...
        'RandXTranslation', [-10 10], ...
        'RandYTranslation', [-10 10]), ...
    'ColorPreprocessing', 'gray2rgb'); % 确保灰度图像转为RGB

augimdsValidation = augmentedImageDatastore([224 224], imdsValidation, ...
    'ColorPreprocessing', 'gray2rgb'); % 确保验证集也正确处理

% 使用预训练的网络作为起点
net = resnet50;

% 获取类别数量
numClasses = numel(categories(imds.Labels));

% 替换网络的最后一个全连接层以匹配类别数
lgraph = layerGraph(net);
lgraph = replaceLayer(lgraph, 'fc1000', fullyConnectedLayer(numClasses, 'WeightLearnRateFactor', 10, 'BiasLearnRateFactor', 10));

% 替换分类层
lgraph = replaceLayer(lgraph, 'ClassificationLayer_fc1000', classificationLayer); % 确保使用正确的层名

% 设置训练选项
options = trainingOptions('sgdm', ...
    'InitialLearnRate', 0.01, ...
    'MaxEpochs', 20, ...
    'MiniBatchSize', 32, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', augimdsValidation, ... % 使用处理过的验证集
    'ValidationFrequency', 30, ...
    'Verbose', false, ...
    'Plots', 'training-progress');

% 训练网络
net = trainNetwork(augimdsTrain, lgraph, options);

% 评估模型
YPred = classify(net, augimdsValidation); % 使用处理过的验证集
YValidation = imdsValidation.Labels;
accuracy = sum(YPred == YValidation) / numel(YValidation);
disp(['Validation accuracy: ', num2str(accuracy * 100), '%']);

% 使用模型来识别新的面孔
% 假设 newFace 是你要识别的新面孔的图像变量
% newFace = imread('path_to_new_face_image');
% newFace = processImage(newFace);
% label = classify(net, newFace);
% disp(['The recognized face is: ', char(label)]);
