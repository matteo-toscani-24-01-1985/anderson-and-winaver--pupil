function make_texture_rotated(imgSize,diskRadius,diskReflectance,outfolder,label,repetition)

[xm,ym]=meshgrid((1:imgSize)-imgSize/2,(1:imgSize)-imgSize/2);
diskmask=sqrt(xm.^2+ym.^2)<diskRadius;

background_reflectance=.5;

% generate reflectance image

RefImg= ones(imgSize,imgSize)*background_reflectance;

RefImg(diskmask)=diskReflectance;

%imshow(RefImg)

% now create noisy transmitter medium.
alpha = pinkNoiseAlphaTexture([imgSize imgSize], 2, [0 1]);

IMG=RefImg.*alpha;

rotated = imrotate(IMG,90);
rotated(diskmask)=IMG(diskmask);
IMG=rotated;
imwrite(IMG,[outfolder '/R' num2str(repetition) '_L' num2str(label) '.png'])
