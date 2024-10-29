% 加载数据
load('Testdata.mat'); % 假设数据存储在变量data中

% 初始化变量
numMeasurements = size(Undata, 1);
centerFrequency = 0;
pathX = [];
pathY = [];
pathZ = [];

% 频谱分析
for i = 1:numMeasurements
    % 对每个测量值进行FFT
    Y = fft(Undata(i, :));
    freq = linspace(0, 1, size(Undata, 2)); % 假设采样频率为1Hz
    % 找到中心频率
    [peakValue, peakIndex] = max(abs(Y));
    if peakValue > abs(centerFrequency)
        centerFrequency = peakValue;
        centralIndex = peakIndex;
    end
end

% 过滤数据
filterWidth = 10; % 根据数据调整
for i = 1:numMeasurements
    Y = fft(Undata(i, :));
    Y(centralIndex-filterWidth:centralIndex+filterWidth) = 0;
    Y = ifft(Y);
    Y = real(Y);
    
    % 存储路径
    pathX = [pathX, Y(1)];
    pathY = [pathY, Y(2)];
    pathZ = [pathZ, Y(3)];
end

% 绘制路径
figure;
plot3(pathX, pathY, pathZ);
xlabel('X');
ylabel('Y');
zlabel('Z');
title('弹珠的路径');

% 确定破碎点
breakPointX = pathX(end);
breakPointY = pathY(end);
breakPointZ = pathZ(end);

% 输出破碎点位置
fprintf('在第20次数据测量时，弹珠位于：(%f, %f, %f)\n', breakPointX, breakPointY, breakPointZ);
