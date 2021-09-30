%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% If you use this code and its associated data (e.g. images) or results in your publication, please cite the paper, Thanks:
%% X. Fang, Q. Zhou, J. Shen, C. Jacquemin,L. Shao. Text Image Deblurring Using Kernel Sparsity Prior. 
%% IEEE Transactions on Cybernetics, vol. PP, no.99, pp.1-12, 2018.
%% Contact:
%% Xianyong Fang (fangxianyong@ahu.edu.cn)
%% Qiang Zhou (zhqiang@ahu.edu.cn)
%% Jianbing Shen (shenjianbing@bit.edu.cn)
%% Christian Jacquemin £¨christian.jacquemin@limsi.fr)
%% Ling Shao (ling.shao@uea.ac.uk)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;
close all;
addpath(genpath('cho_code'));
addpath(genpath('Skeleton1'));
addpath(genpath('pan_code'));
addpath(genpath('Skeleton2'));

%% set the parameters
fprintf('setting the parameters...\n');

% set the source and result file names and addresses
blurImageName = 'text2';
blurImageAddress = strcat('images/', blurImageName, '.png');
latentKernelAddr_no_denoise = strcat ('images/results/', blurImageName, '_kernel_nodenoise.png');
latentImageAddr_no_denoise = strcat ('images/results/', blurImageName, '_nodenoise.png');
latentKernelAddr_denoised =   strcat ('images/results/', blurImageName, '_kernel_denoised.png');
latentImageAddr_denoised = strcat ('images/results/', blurImageName, '_denoised.png');

% iterations and kernel size
opts.prescale = 1; %%downsampling
opts.xk_iter = 5; %% the iterations
opts.k_thresh = 20; 
opts.kernel_size = 53; % kernel size

% denoising parameters
ker_denoised = 1;       % denoising or not
skeleton_method = 1;    % skeleton detection method
threshold = 0.3;        % local threshold
threshold_all = 0.1;    % global threshold

% model related parameters
gammaL_pixel = 4e-3;
gammaL_grad = 4e-3;
lambda_tv = 0.001; 
lambda_l0 = 1e-3; 
weight_ring = 1;

y = imread(blurImageAddress);
if size(y,3)==3
    yg = im2double(rgb2gray(y));
else
    yg = im2double(y);
end

%%  deblurring
[kernel, interim_latent] = blind_deconv(yg, gammaL_pixel, gammaL_grad, opts);
y = im2double(y);

% Final Deblur: 
Latent = ringing_artifacts_removal(y, kernel, lambda_tv, lambda_l0, weight_ring);
imwrite(Latent,latentImageAddr_no_denoise);
k = kernel - min(kernel(:));
k = k./max(k(:));
imwrite(k,latentKernelAddr_no_denoise);

%% kernel denoising
if ker_denoised == 1
    denoised_k = kernel_denoised(k,threshold,threshold_all,skeleton_method);
    Latent = ringing_artifacts_removal(y, denoised_k, lambda_tv, lambda_l0, weight_ring);
    imwrite(Latent,latentImageAddr_denoised);
    imwrite(mat2gray(denoised_k),latentKernelAddr_denoised);
end



