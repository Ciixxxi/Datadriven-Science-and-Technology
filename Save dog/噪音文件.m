clear all; close all; clc;
load('D:\learngit\Datadriven_homework\Testdata.mat'); % 确保这个文件包含Undata变量

L=15; % spatial domain
n=64; % Fourier modes
x2=linspace(-L,L,n+1); x=x2(1:n); y=x; z=x;
k=(2*pi/(2*L))*[0:(n/2-1) -n/2:-1]; ks=fftshift(k);

[X,Y,Z]=meshgrid(x,y,z); 
[Kx,Ky,Kz]=meshgrid(ks,ks,ks);

figure; % 创建一个新的图形窗口

% Undata的形状为（20，64*64*64）
for j=1:size(Undata, 1) % 使用Undata的第一维大小作为循环条件
    Un = reshape(Undata(j, :), n, n, n); % 重塑每个切片
    isosurface(X, Y, Z, abs(Un), 0.4);
    axis([-20 20 -20 20 -20 20]), grid on, drawnow;
    pause(1); % 如果你想要动画效果，保留这个命令
end