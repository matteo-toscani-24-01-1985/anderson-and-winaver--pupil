
clear; close all;
rng(1701)
% PARAMETERS
outfolder='./images_rotated/';
mkdir(outfolder);

imgSize = 256;

diskRadius = 45;


%diskReflectance = 0.6;  % true uniform reflectance
nlabels=20;
labels= linspace(.2,.8,nlabels);
nrepetitions=1000;
for label=1:length(labels)
parfor i=1:nrepetitions
    
make_texture_rotated(imgSize,diskRadius,labels(label),outfolder,label,i)
end
end
% subplot(1,2,1)
% imshow(RefImg)
% subplot(1,2,2)
% imshow(IMG)


