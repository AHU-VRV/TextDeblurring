function k = estimate_psf_L0( y1, y2, x1, x2, k, psf_size)
Denormin2 = abs(fft2(ifftshift(x1))).^2+abs(fft2(ifftshift(x2))).^2;
gamma_k = 2e-3;
seita1 = 2000;
h = k;
t = (k^2)< gamma_k/seita1;
h(t)=0;

Normin1 =conj(fft2(ifftshift(x1))).*fft2(ifftshift(y1))+conj(fft2(ifftshift(x2))).*fft2(ifftshift(y2));
Normin1 = Normin1 + gamma_k*psf2otf(h, size(x1));

b = real(otf2psf(Normin1, psf_size));
p.m = Denormin2;
p.img_size = size(y1);
p.psf_size = psf_size;
p.lambda = gamma_k;

k_prev = ones(psf_size) / prod(psf_size);
k = conjgrad(k_prev, b, 20, 1e-5, @compute_Ax, p);

k( k < max(k(:) * 0.05) ) = 0;
k= k/sum(k(:));

fprintf('.');
end

function y = compute_Ax(x, p)
    x_f = psf2otf(x, p.img_size);
    y = otf2psf(p.m .* x_f, p.psf_size);
    y = y + p.lambda * x;
end
