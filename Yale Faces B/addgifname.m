% 定义未裁剪图像数据集的文件夹路径
sourceFolderPath = 'D:\learngit\Datadriven_homework\homework2\yalefaces_uncropped\yalefaces';
targetFolderPath = 'D:\learngit\Datadriven_homework\homework2\yalefaces_uncropped\gifyalefaces';

% 确保目标文件夹存在
if ~exist(targetFolderPath, 'dir')
    mkdir(targetFolderPath);
end

% 获取文件夹中所有文件的信息
files = dir(fullfile(sourceFolderPath, '*.*'));

% 初始化文件计数器
fileCounter = 1;

% 循环遍历所有文件
for i = 1:length(files)
    % 获取文件的完整路径
    filePath = fullfile(sourceFolderPath, files(i).name);
    
    % 检查文件是否不是目录且不是隐藏文件
    if ~files(i).isdir && ~ismember(files(i).name, {'.', '..'})
        % 获取文件的文件名和扩展名
        [fileName, ~, ~] = fileparts(files(i).name);
        
        % 构建新的文件名（添加.gif扩展名）
        newFileName = sprintf('gif_%02d.gif', fileCounter);
        
        % 构建新的文件路径
        newFilePath = fullfile(targetFolderPath, newFileName);
        
        % 复制文件
        copyfile(filePath, newFilePath);
        
        % 更新文件计数器
        fileCounter = fileCounter + 1;
        
        % 显示复制的文件信息以进行调试
        fprintf('Copied: %s to %s\n', files(i).name, newFileName);
    end
end

% 显示目标文件夹中的文件以进行调试
disp('Files in the target folder:');
filesInTarget = dir(fullfile(targetFolderPath, '*.gif'));
for i = 1:length(filesInTarget)
    fprintf('%s\n', filesInTarget(i).name);
end