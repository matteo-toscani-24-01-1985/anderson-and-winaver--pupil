clear all
close all

% compute low_level diss mat
dlow=dir('./statistics/*.mat');

dim=dir('./images/*.png'); % they should be the same, they are othered the same way.
A=nan(length(dlow),7);
for i=1:length(dlow)
load(['./statistics/' dlow(i).name])
A(i,:)=stats;
end

AA = sum(A.^2,2);

D2 = AA + AA' - 2*(A*A');

D2(D2<0) = 0; % numerical safety
Dlow = sqrt(D2);

% now each of the low
for lo=1:7
    AA = sum(A(:,lo).^2,2);

D2 = AA + AA' - 2*(A(:,lo)*A(:,lo)');

D2(D2<0) = 0; % numerical safety
Dlows(:,:,lo) = sqrt(D2);
end


% now reflectance
%read reflecances from names
nlabels=20;
labels= linspace(.2,.8,nlabels);
LS=nan(size(dlow));
for i=1:length(dlow)
    L = regexp(dlow(i).name, 'L(\d+)', 'tokens');
LS(i) = str2double(L{1}{1});
end
Reflectances=labels(LS)';

AA = sum(Reflectances.^2,2);

D2 = AA + AA' - 2*(Reflectances*Reflectances');

D2(D2<0) = 0; % numerical safety
Dref= sqrt(D2);


% now do RDS per layer
layers= {'input','conv1','bn1','relu1','pool1','conv2_1','bn2_1','relu2_1','conv2_2','bn2_2','add1','relu_add1','fc_dummy1','gap','fc_final','softmax','classoutput'};
CORS=nan(length(layers),9);
for l=1:length(layers)
    load(['./layer_responses/' layers{l} '.mat'])
   CORS(l,1)= corr(D(:),Dlow(:));
   CORS(l,2)= corr(D(:),Dref(:));
for lo=1:7
    tmp=Dlows(:,:,lo);
   CORS(l,2+lo)= corr(D(:),tmp(:));
end
end

%stats = [diskMean, diskStd, bgMean, bgStd, diffMean, michelson, ratio];
figure
hleg(1)=plot(1:15,CORS(1:15,1),'g-','LineWidth',3);
hold on
hleg(2)=plot(1:15,CORS(1:15,2),'r-','LineWidth',3);
cols=[0 0 1; 0 0 .3; 1 0 1; .3 0 .3; 1 1 0; 0 1 1; 0 .5 .5 ];
for i=1:(size(CORS,2)-2)
   % col=ones(1,3)*( (i-1)/6) *.6;
    col=cols(i,:);
    hleg(i+2)=plot(1:15,CORS(1:15,i+2),'k-','color',col,'LineWidth',2);
end
legend(hleg,{'low level','reflectance','disk mean','disk std','bg mean','bg std', 'mean disk - mean bg','michelson contrast','ratio'})
legend box off
set(gca,'LineWidth',3,'FontSize',20,'XTick',1:15,'XTickLabel',layers)
box off
ylabel('correlation','FontSize',20)
save RSA_RESULTS

% correlate stats with reflectance
labstats={'disk mean','disk std','bg mean','bg std', 'mean disk - mean bg','michelson contrast','ratio'};
for s=1:size(A,2)
  cc=  corr(LS,A(:,s));
fprintf([labstats{s} ' r:' num2str(cc) '\n'])  
end