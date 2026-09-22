clear all
close all

imgSize = 256;
mkdir statistics
diskRadius = 45;
[xm,ym]=meshgrid((1:imgSize)-imgSize/2,(1:imgSize)-imgSize/2);
diskmask=sqrt(xm.^2+ym.^2)<diskRadius;


d=dir('./images/*.png');

parfor i=1:length(d)
    name=d(i).name;
    I=double(imread(['./images/' name]))/255;
   outFile=['./statistics/low_level_' name(1:(end-4)) '.mat'];
   
   compute_low_level_stats(I, diskmask, outFile)
end