function [AVERAGES,MATCHES,ALL_SIGNALS]=ANALYSE(filename)
% example
if nargin <1
filename ='S01';
end

baselinetime=2000;
% trials are incremented before sending the message END, so that end of
% trial 1 is trial 2 end

% extract all messages to search for the patter trial x start; trial x+1
% end
fid=fopen(['./DATA/' filename '_E.asc']);

count=0;
tablemessages=nan(1000,3);
while ~feof(fid)
    Line_tmp = fgetl(fid);
    if contains(Line_tmp,'MSG') &  contains(Line_tmp,'trialid') 
      
     Line_tmp_seg=segmentline(Line_tmp);
startstop=2-strcmp(Line_tmp_seg{5},'START'); % start is 1, 2 is end

timestamp=str2num(Line_tmp_seg{2});
trialid=str2num(Line_tmp_seg{4});
count=count+1;
tablemessages(count,:)=[timestamp trialid startstop];
    end
end
tablemessages=tablemessages(~isnan(tablemessages(:,1)),:);

% look for when it's col2=
change_trial=[0;diff(tablemessages(:,2))];

trialEnds_Id=tablemessages(find(change_trial==1),2)-1;
trialEnds_End=tablemessages(find(change_trial==1),1);
trialEnds_Start=tablemessages(find(change_trial==1)-1,1);
% checked the differences, it makes sense as it is nearly always the same,
% but it's 2235 instead of 2k
copyfile(['./DATA/' filename '_S.asc'],['./DATA/' filename '_S.txt'])
rawGaze = readtable(['./DATA/' filename '_S.txt'], ...
    'Delimiter',{' ','\t'}, ...
    'MultipleDelimsAsOne',true);
% cut pupil traces
for trial=1:length(trialEnds_End)
trialposition= find((rawGaze.Var1>=trialEnds_Start(trial))&(rawGaze.Var1<trialEnds_End(trial)));
pupiltrial=rawGaze.Var4(trialposition);
baselineposition= find((rawGaze.Var1<trialEnds_Start(trial))&(rawGaze.Var1>=(trialEnds_Start(trial) - baselinetime)));
pupilbaseline=rawGaze.Var4(baselineposition);
%close all;plot([pupilbaseline ;pupiltrial])
trialdata{trial,1}=pupilbaseline;
trialdata{trial,2}=pupiltrial;
end

% average per condition
% get matlab responses file
listoffile=dir(['./DATA/' filename '*']);
for i=1:length(listoffile)
    tmp=listoffile(i).name;
if contains(tmp,'.mat')
    nn=tmp;
end
end
load(['./DATA/' nn],'RESPONSES')

%RESPONSES.TABLE

% TABLE=[TABLE; [bg rot rep]];
figure
indexes=1:2235;
for rot=1:2
    for bg=1:2
        pos=find( (RESPONSES.TABLE(:,1)==bg) & (RESPONSES.TABLE(:,2)==rot));
baseline=[];
stimulus=[];
        for i=1:length(pos)
          
          
           baseline=[baseline; trialdata{pos(i),1}'];
           
           stimulus=[stimulus; interp1(1:length(trialdata{pos(i),2}'),trialdata{pos(i),2}',indexes)];
        
           
            end
     stimave=   nanmean(stimulus);
     baseave= nanmean(baseline);


       stimmed=   nanmedian(stimulus);
     basemed= nanmedian(baseline);

 ALL_SIGNALS{bg,rot,1}=baseline;
 ALL_SIGNALS{bg,rot,2}=stimulus;
 
     subplot(2,2,bg+2*(rot-1))
     plot(1:2000,baseave,'r-','LineWidth',3);
     hold on
     plot(indexes+2000,stimave,'b-','LineWidth',3)


     plot(1:2000,basemed,'r--','LineWidth',3);
     hold on
     plot(indexes+2000,stimmed,'b--','LineWidth',3)


plot(1:2000,baseline,'r-','LineWidth',.5);
     plot(indexes+2000,stimulus,'b-','LineWidth',.5)
    % ylim([0 3000])
    % store averages
     % AVERAGES{bg,rot,1}=baseave;
     % AVERAGES{bg,rot,2}=stimave;
      % store medians
         AVERAGES{bg,rot,1}=basemed;
      AVERAGES{bg,rot,2}=stimmed;
      MAXS(bg,rot)= max(max(stimulus(:)),max(baseline(:)));
    end
end

background={'dark bg','light bg'};
rotations ={'upright','rotated'};
for bg=1:2 % 1 is dark
   for rot=1:2 % 1 is original
        subplot(2,2,bg+2*(rot-1))
        ylim([0 max(MAXS(:))])
        title([rotations{rot} ' ' background{bg}])
   end
end

% from binda baseline 500 ms before
% plot baseline corrected - subtracted, like in binda (Pupil constrictions
% to photographs of the sun)
figure
subplot(1,2,1)
symbs={'-','--'};
cols={'r','b'};
for rot=1:2
    for bg=1:2
        tmp=AVERAGES{bg,rot,2};
        base= AVERAGES{bg,rot,1};
base=base((end-500):end);
tmp=tmp(1:2000)-mean(base);
plot(1:2000,tmp,[cols{bg} symbs{rot}],'LineWidth',3)
hold on
    end
end
box off
xlabel('time (ms)','FontSize',20)
ylabel('pupile size- baseline corrected','FontSize',20)
axis square
set(gca,'LineWidth',3,'FontSize',20)

% behavioral response
RESPONSES.lummatch=RESPONSES.lummatch(2:end); % because it starts with empty
for rot=1:2
    for bg=1:2
        pos=find( (RESPONSES.TABLE(:,1)==bg) & (RESPONSES.TABLE(:,2)==rot));
        MATCHES(bg,rot)=mean(RESPONSES.lummatch(pos));
        MATCHES_ERROR(bg,rot)=std(RESPONSES.lummatch(pos))/sqrt(length(pos));
    end
end

subplot(1,2,2)


sty={'-','--'};
for rot=1:2
   hleg(rot)= errorbar(1:2,MATCHES(:,rot),MATCHES_ERROR(:,rot),['k' sty{rot}],'LineWidth',3);
    hold on
end
box off
ylabel('lightness match','FontSize',20)
axis square
set(gca,'LineWidth',3,'FontSize',20,'XTick',1:2,'XTickLabel',{'Dark','Light'})
legend(hleg,{'upright','rotated'});
xlim([.5 2.5])