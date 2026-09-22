function alpha = pinkNoiseAlphaTexture(sz, exponent, range)
% pinkNoiseAlphaTexture Generate 1/f^alpha noise as a transparency mask
%
% alpha = pinkNoiseAlphaTexture(sz, exponent, range, seed)
%
% INPUTS:
%   sz        - [rows cols] size of texture (e.g., [512 512])
%   exponent  - spectral exponent (1 = pink, 0 = white, 2 = redder)
%   range     - [min max] transparency values (e.g., [0 1] or [0.2 0.8])
%   seed      - (optional) random seed for reproducibility
%
% OUTPUT:
%   alpha     - normalized transparency map in specified range

% if nargin < 4
%     seed = 'shuffle';
% end
% rng(seed);

rows = sz(1);
cols = sz(2);

% --- white noise in Fourier domain ---
noise = randn(rows, cols) + 1i * randn(rows, cols);

% --- frequency grid ---
fx = (-floor(cols/2):ceil(cols/2)-1) / cols;
fy = (-floor(rows/2):ceil(rows/2)-1) / rows;
[FX, FY] = meshgrid(fx, fy);
R = sqrt(FX.^2 + FY.^2);

% avoid divide-by-zero at DC
R(R==0) = eps;

% --- 1/f^alpha shaping ---
%filter = R .^ (-exponent/2);
filter = 1./(R.^exponent);
filter(end/2 +1,end/2 +1)=1;
% normalize filter energy
filter = filter / max(filter(:));
filter(end/2 +1,end/2 +1)=1; % put back dc
% apply filter in frequency domain
F = fftshift(noise) .* filter;

% inverse FFT to spatial domain
img = real(ifft2(ifftshift(F)));

% --- normalize to 0–1 ---
img = img - min(img(:));
img = img / max(img(:));

% --- map to desired transparency range ---
alpha = range(1) + img * (range(2) - range(1));

end