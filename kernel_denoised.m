
function denoised_k = kernel_denoised(blur_k,threshold,threshold_all,skeleton_method)

% blur_k(blur_k<max(blur_k(:)/20)) = 0;
if skeleton_method == 1
    [path, pixels] = get_skeleton1(blur_k, 2, 0);
else
    [skel,exy,jxy]=get_skeleton2(blur_k);
    [row,col]=ind2sub(size(skel),find(skel > 0));
    pixels = [row col];
end

[m, n] = size(pixels);
[M, N] = size(blur_k);
opts.kernel_size = M;
mask = zeros(M, N);
mask1 = zeros(M, N);
mask2 = zeros(M,N);

%% global denoising
blur_k(blur_k<max(blur_k(:)*threshold_all)) = 0;

%% local denoising
width=round(M/4);

for i=1:m
    for j=0:width
        k1 = pixels(i,1)+j;
        if k1>M || blur_k(k1,pixels(i,2))==0
            break;
        else
            if blur_k(k1,pixels(i,2))>threshold*blur_k(pixels(i,1),pixels(i,2))
                mask1(k1,pixels(i,2))=1;
            end
        end
    end
    for j=0:width
        k1 = pixels(i,1)-j;
        if k1<1 || blur_k(k1,pixels(i,2))==0
            break;
        else
            if blur_k(k1,pixels(i,2))>threshold*blur_k(pixels(i,1),pixels(i,2))
                mask1(k1,pixels(i,2))=1;
            end
        end
    end
    for j=0:width
        k2 = pixels(i,2)+j;
        if k2>N || blur_k(pixels(i,1),k2)==0
            break;
        else
            if blur_k(pixels(i,1),k2)>threshold*blur_k(pixels(i,1),pixels(i,2))
                mask1(pixels(i,1),k2)=1;
            end
        end
    end        
    for j=0:width
        k2 = pixels(i,2)-j;
        if k2<1 || blur_k(pixels(i,1),k2)==0
            break;
        else
            if blur_k(pixels(i,1),k2)>threshold*blur_k(pixels(i,1),pixels(i,2))
                mask1(pixels(i,1),k2)=1;
            end
        end
    end
end
for i=1:m
    mask1(pixels(i,1),pixels(i,2))=1;
end
result = blur_k.*mask1;

%% filtering independent noisy pixels
for i=1:m
    for j=0:10
        k1 = pixels(i,1)+j;
        if k1>M || result(k1,pixels(i,2))==0
            break;
        else
            mask(k1,pixels(i,2))=1;
        end
    end
    for j=0:10
        k1 = pixels(i,1)-j;
        if k1<1 || result(k1,pixels(i,2))==0
            break;
        else
            mask(k1,pixels(i,2))=1;
        end
    end
    for j=0:10
        k2 = pixels(i,2)+j;
        if k2>N || result(pixels(i,1),k2)==0
            break;
        else
            mask(pixels(i,1),k2)=1;
        end
    end        
    for j=0:10
        k2 = pixels(i,2)-j;
        if k2<1 || result(pixels(i,1),k2)==0
            break;
        else
            mask(pixels(i,1),k2)=1;
        end
    end
end

%% keep the pixels along the skeleton
for i=1:m
    mask(pixels(i,1),pixels(i,2))=1;
end
result = blur_k.*mask;
sumk = sum(result(:));
result = result ./ sumk;
denoised_k =result;

