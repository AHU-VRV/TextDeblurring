function [k, gammaL_pixel, gammaL_grad, S] = blind_deconv_main(blur_B, k, ...
                                    gammaL_pixel, gammaL_grad, threshold, opts)
% Do single-scale blind deconvolution using the input initializations
% 
% I and k. The cost function being minimized is: min_{I,k}
%  |B - I*k|^2  + \gamma*|k|_2 + lambda_pixel*|I|_0 + lambda_grad*|\nabla I|_0
%
%% Input:
% @blur_B: input blurred image 
% @k: blur kernel
% @lambda_pixel: the weight for the L0 regularization on intensity
% @lambda_grad: the weight for the L0 regularization on gradient
%
% Ouput:
% @k: estimated blur kernel 
% @S: intermediate latent image
%
% The Code is created based on the method described in the following paper 
%        Jinshan Pan, Zhe Hu, Zhixun Su, and Ming-Hsuan Yang,
%        Deblurring Text Images via L0-Regularized Intensity and Gradient
%        Prior, CVPR, 2014. 

%   Author: Jinshan Pan (sdluran@gmail.com)
%   Date  : 05/18/2014
%=====================================
%% Note: 
% v4.0 add the edge-thresholding 
%=====================================
% derivative filters
dx = [-1 1; 0 0];
dy = [-1 0; 1 0];
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2013-08-11
H = size(blur_B,1);    W = size(blur_B,2);
blur_B_w = wrap_boundary_liu(blur_B, opt_fft_size([H W]+size(k)-1));
blur_B_tmp = blur_B_w(1:H,1:W,:);
Bx = conv2(blur_B_tmp, dx, 'valid');
By = conv2(blur_B_tmp, dy, 'valid');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
for iter = 1:opts.xk_iter
   %% The following are used on 2013-08-11
   %S = L0Deblur_whole(blur_B_w, k, lambda_pixel, lambda_grad, 2.0);
   %% Modified on 2013-08-27
   if gammaL_pixel~=0
       %% For acceleration???
       if max(size(blur_B_w))<2024
           S = L0Deblur_whole(blur_B_w, k, gammaL_pixel, gammaL_grad, 2.0);
       else %% With GPU type acceleration
%            S = L0Deblur_whole(blur_B_w, k, lambda_pixel, lambda_grad, 2.0);
           S = L0Deblur_whole_fast(blur_B_w, k, gammaL_pixel, gammaL_grad, 2.0);
       end
       S = S(1:H,1:W,:);
   else
       %% L0 deblurring
       S = L0Restoration(blur_B, k, gammaL_grad, 2.0);
   end
   %% Necessary for refining gradient ???
  [latent_x, latent_y, threshold]= threshold_pxpy_v1(S,max(size(k)),threshold); 
  %% The results without thresholding gradients are almost 
  %% the same to those of with thresholding gradients... 
%   latent_x = conv2(S, dx, 'valid');
%   latent_y = conv2(S, dy, 'valid');
  k_prev = k;
%   using FFT method for estimating kernel 
  k = estimate_psf_L0(Bx, By, latent_x, latent_y, 2, size(k_prev));

  %%
  fprintf('pruning isolated noise in kernel...\n');
  CC = bwconncomp(k,8);
  for ii=1:CC.NumObjects
      currsum=sum(k(CC.PixelIdxList{ii}));
      if currsum<.1 
          k(CC.PixelIdxList{ii}) = 0;
      end
  end
  k(k<0) = 0;
  k=k/sum(k(:));
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Parameter updating
  if gammaL_pixel~=0;
      gammaL_pixel = max(gammaL_pixel/1.1, 1e-4);
  else
      gammaL_pixel = 0;
  end
  if gammaL_grad~=0;
      gammaL_grad = max(gammaL_grad/1.1, 1e-4);
  else
      gammaL_grad = 0;
  end
  kw = k - min(k(:));
  kw = kw./max(kw(:));
end;
k(k<0) = 0;  
k = k ./ sum(k(:));
