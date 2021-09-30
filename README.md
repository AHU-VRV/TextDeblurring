# Text Image Deblurring Using Kernel Sparsity Prior

This repository demos the algorithm in the paper titled [Text Image Deblurring Using Kernel Sparsity Prior](https://fangxianyong.github.io/home/papers/tcy20textdeblurring.pdf), by Xianyong Fang, et al. at IEEE Trans. Cybernetics, 2020.

The code is tested in MATLAB 2016a(64bit) under the MS Windows 10 64bit version. For algorithmic details, please refer to our paper. Please also start from 'demo.m' for more details.

## How to use
1. unpack the package
2. Run "demo.m" to try the example included in this package.

User specified parameter:
1. Kernel estimation part:
'kernel_size':   the size of blur kernel
'gammaL_pixel':  the weight for the L0 regularization on intensity (typically set as 4e-3)
'gammaL_grad':   the weight for the L0 regularization on gradient (typically set as 4e-3)

2. Non-blind deconvolution part:
'lambda_tv':     the weight for the Laplacian prior based deconvolution [1e-3,1e-2];
'lambda_l0':     the weight for the L0 prior based deconvolution typically set as 1e-3, the best range is [1e-4, 2e-3].
'weight_ring':   the larger values help suppress the ringing artifacts. weight_ring=0 imposes no suppression.

3. Kernel denoising part:
'ker_denoised':       denoising or not (1 for denoising, others for no denoising)
'skeleton_method':    skeleton detection method (1 for Yim et al., others for Howe et al.)
'threshold':          local threshold, typically set as 0.3, the best range is [0.1, 0.5]
'threshold_all':      global threshold, typically set as 0.1, the best range is [0.05, 0.2]

## Citation
If you find this code or its associated data (e.g. images) is useful, please cite the paper, Thanks.

X. Fang, Q. Zhou, J. Shen, C. Jacquemin, L. Shao. [Text Image Deblurring Using Kernel Sparsity Prior](https://fangxianyong.github.io/home/papers/tcy20textdeblurring.pdf). 
IEEE Transactions on Cybernetics, vol. 50, no.3, pp.997-1008, 2020.

## Contacts
Should you have any question regarding this software and its corresponding results, please contact:

Xianyong Fang (fangxianyong@ahu.edu.cn)

Qiang Zhou (zhqiang@ahu.edu.cn)

Jianbing Shen (shenjianbing@bit.edu.cn)

Christian Jacquemin （christian.jacquemin@limsi.fr)

Ling Shao (ling.shao@uea.ac.uk)

