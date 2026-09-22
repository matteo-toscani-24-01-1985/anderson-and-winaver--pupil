
clear; close all;

% PARAMETERS

imgSize = 512;

diskRadius = 90;


diskReflectance = 0.6;  % true uniform reflectance

[xm,ym]=meshgrid((1:imgSize)-imgSize/2,(1:imgSize)-imgSize/2);
diskmask=sqrt(xm.^2+ym.^2)<diskRadius;

background_reflectance=.5;

% generate reflectance image

RefImg= ones(imgSize,imgSize)*background_reflectance;

RefImg(diskmask)=diskReflectance;

%imshow(RefImg)

% now create noisy transmitter medium.
alpha = pinkNoiseAlphaTexture([imgSize imgSize], 2, [0 1], 1701);

IMG=RefImg.*alpha;

subplot(1,2,1)
imshow(RefImg)
subplot(1,2,2)
imshow(IMG)


