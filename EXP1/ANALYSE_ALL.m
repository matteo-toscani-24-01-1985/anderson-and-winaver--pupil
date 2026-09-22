clear all
close all
Subjects =[1:19 21]; % labelling issue here, we don't have sub 21

monxyY=[0.6413,  0.3274,  57.61 ; 0.3104, 0.6256, 256.98; 0.1514, 0.0568, 26.2 ];


for s=1:length(Subjects)
    if length(num2str(Subjects(s)))==1
        [AVERAGES,MATCHES,SIGNALS]=      ANALYSE(['N0' num2str(Subjects(s))]);
    else
        [AVERAGES,MATCHES,SIGNALS]= ANALYSE(['N' num2str(Subjects(s))]);
    end
    AVERAGES_ALL{s}=AVERAGES;
      SIGNALS_ALL{s}=SIGNALS;
      MATCHES_ALL(:,:,s)=MATCHES;
end

clear AVERAGES
for rot=1:2
    for bg=1:2
        base = zeros(length(Subjects),2000);
        siGnal = zeros(length(Subjects),2235);
        for s=1:length(Subjects)
            base(s,:)=  AVERAGES_ALL{s}{bg,rot,1}  ;
            siGnal(s,:)=  AVERAGES_ALL{s}{bg,rot,2}  ;
        end
        AVERAGES{bg,rot,1}=nanmean(base);
       
        AVERAGES{bg,rot,2}=nanmean(siGnal);
        ERRORS{bg,rot,1}=nanstd(base)/sqrt(length(Subjects));
        ERRORS{bg,rot,2}=nanstd(siGnal)/sqrt(length(Subjects));

    end
end
figure
symbs={'-','--'};
cols={'r','b'};
for rot=1:2
    for bg=1:2
        tmp=AVERAGES{bg,rot,2};
        base= AVERAGES{bg,rot,1};
        base=base((end-500):end);
        tmp=tmp(1:2200)-mean(base);
        errtmp=ERRORS{bg,rot,2};
errtmp=errtmp(1:2200);
        plot(1:2200,tmp,[cols{bg} symbs{rot}],'LineWidth',3)
        hold on
        hf=fill([1:2200 fliplr(1:2200)],[tmp-errtmp fliplr(tmp+errtmp)],cols{bg});
        hf.FaceAlpha=.2;
        hf.EdgeColor='None';

    end
end
box off
xlabel('time (ms)','FontSize',20)
ylabel('pupile size- baseline corrected (Eyelink Units)','FontSize',20)
axis square
set(gca,'LineWidth',3,'FontSize',20)
xlim([ 0 2200])


for bg=1:2

    %  baseO = zeros(length(Subjects),2000);
    siGnalO = zeros(length(Subjects),2235);
    % baseR = zeros(length(Subjects),2000);
    siGnalR = zeros(length(Subjects),2235);
    for s=1:length(Subjects)
    
        baseO=  AVERAGES_ALL{s}{bg,1,1}  ;
        siGnalO(s,:)=  AVERAGES_ALL{s}{bg,1,2} -mean(baseO((end-500):end)) ;       % correct for baseline
        baseR=  AVERAGES_ALL{s}{bg,2,1}  ;
        siGnalR(s,:)=  AVERAGES_ALL{s}{bg,2,2} -mean(baseR((end-500):end)) ;       % correct for baseline
    end

    % downsample

  dowsn=1024;
    time1=1:2200;
    time2=linspace(1,2200,dowsn);
    clear SiGnalR_down SiGnalO_down
    for s=1:length(Subjects)

        tmp=    siGnalO(s,1:2200);
        tmp_down = downsample_moving(tmp, dowsn);
        SiGnalO_down(s,:)=tmp_down;
        % plot(time1,tmp,'LineWidth',3)
        % hold on
        % plot(time2,tmp_down,'r-','LineWidth',1)
        % error pd

        tmp=    siGnalR(s,1:2200);
        tmp_down = downsample_moving(tmp, dowsn);
        SiGnalR_down(s,:)=tmp_down;
    end
    % leave one subject out, classify

   clear PERF
    for subout=1:length(Subjects)
        subin=find([1:length(Subjects)]~=subout);

        for t=1:size(SiGnalO_down,2)
sample = [SiGnalO_down(subout ,t) SiGnalR_down(subout ,t) ];
gt= [0 1];

training = [SiGnalO_down(subin ,t)' SiGnalR_down(subin ,t)' ];
group= [zeros(1,length(subin)) ones(1,length(subin))];
indshuffle=randsample(1:length(group),length(group),false);
         PERF(t,subout)=  mean(gt'== classify(sample',training(indshuffle)',group(indshuffle)'));
        end
    end
mPERF(:,bg)=mean(PERF,2);
end






% try t-test every time point
clear PS BFS TS
for bg=1:2

    %  baseO = zeros(length(Subjects),2000);
    siGnalO = zeros(length(Subjects),2235);
    % baseR = zeros(length(Subjects),2000);
    siGnalR = zeros(length(Subjects),2235);
    for s=1:length(Subjects)
        baseO=  AVERAGES_ALL{s}{bg,1,1}  ;
        siGnalO(s,:)=  AVERAGES_ALL{s}{bg,1,2} -mean(baseO((end-500):end));       % correct for baseline
        baseR=  AVERAGES_ALL{s}{bg,2,1}  ;
        siGnalR(s,:)=  AVERAGES_ALL{s}{bg,2,2} -mean(baseR((end-500):end));       % correct for baseline
    end

    % downsample


    time1=1:2200;
  
    time2=linspace(1,2200,dowsn);
    clear SiGnalR_down SiGnalO_down
    for s=1:length(Subjects)

        tmp=    siGnalO(s,1:2200);
        tmp_down = downsample_moving(tmp, dowsn);
        SiGnalO_down(s,:)=tmp_down;
        % plot(time1,tmp,'LineWidth',3)
        % hold on
        % plot(time2,tmp_down,'r-','LineWidth',1)
        % error pd

        tmp=    siGnalR(s,1:2200);
        tmp_down = downsample_moving(tmp, dowsn);
        SiGnalR_down(s,:)=tmp_down;
    end

%         for t=1:size(SiGnalO_down,2)
% [~,PS(t,bg),~,stats]=ttest(SiGnalO_down(: ,t)-SiGnalR_down(: ,t)) ;
% TS(t,bg)=stats.tstat;
% BFS(t,bg)=t1smpbf(-stats.tstat,length(Subjects));
%        end
   
SIGNALS_TO_COMPUTE_EFFECT{bg,1}=SiGnalO_down;
SIGNALS_TO_COMPUTE_EFFECT{bg,2}=SiGnalR_down;
end

% compute effect of background

BG_EFFECT_O= SIGNALS_TO_COMPUTE_EFFECT{1,1} - SIGNALS_TO_COMPUTE_EFFECT{2,1};
BG_EFFECT_R= SIGNALS_TO_COMPUTE_EFFECT{1,2} - SIGNALS_TO_COMPUTE_EFFECT{2,2};

mBG_EFFECT_O=mean(BG_EFFECT_O,1);
mBG_EFFECT_R=mean(BG_EFFECT_R,1);

seBG_EFFECT_O=std(BG_EFFECT_O,0,1)/sqrt(size(BG_EFFECT_O,1));
seBG_EFFECT_R=std(BG_EFFECT_R,0,1)/sqrt(size(BG_EFFECT_O,1));
%%
OneCM=1080/30;
%mBG_EFFECT_O=mBG_EFFECT_O/OneCM;
%mBG_EFFECT_R=mBG_EFFECT_R/OneCM;
%seBG_EFFECT_O=seBG_EFFECT_O/OneCM;
%seBG_EFFECT_R=seBG_EFFECT_R/OneCM;
figure
plot(time2,mBG_EFFECT_O,'r-','LineWidth',3)
hold on
plot(time2,mBG_EFFECT_R,'b-','LineWidth',3)
xlabel('time (ms)','FontSize',20)
ylabel('Background Effect (eyelink units)','FontSize',20)

  hfR=fill([time2 fliplr(time2)],[mBG_EFFECT_R-seBG_EFFECT_R fliplr(mBG_EFFECT_R+seBG_EFFECT_R)],'b');
        hfR.FaceAlpha=.2;
        hfR.EdgeColor='None';

  hfO=fill([time2 fliplr(time2)],[mBG_EFFECT_O-seBG_EFFECT_O fliplr(mBG_EFFECT_O+seBG_EFFECT_O)],'r');
        hfO.FaceAlpha=.2;
        hfO.EdgeColor='None';        
box off
set(gca,'LineWidth',3,'FontSize',20)

diffdata = BG_EFFECT_R - BG_EFFECT_O;


for t=1:length(time2)
  [~,PS(t),~,stats] = ttest(diffdata(:,t));
%[~,PS(t),~,stats]=ttest(BG_EFFECT_R(: ,t)-BG_EFFECT_O(: ,t)) ;
TS(t)=stats.tstat;
BFS(t)=t1smpbf(-stats.tstat,length(Subjects));

end


%%% try clustersize
clusters= PS<0.05;

% գտ contiguous clusters
cluster_starts = find(diff([0 clusters]) == 1);
cluster_ends   = find(diff([clusters 0]) == -1);

nClusters = length(cluster_starts);
cluster_mass = zeros(1,nClusters);

for c = 1:nClusters
    idx = cluster_starts(c):cluster_ends(c);
    cluster_mass(c) = sum(abs(TS(idx))); % or sum(TS(idx)) if directional
end

rng(1701)
nPerm = 10000;
max_cluster_mass_perm = zeros(1,nPerm);

for p = 1:nPerm
    
    % sign flip per subject
    %flip = (rand(size(diffdata,1),1) > 0.5)*2 - 1;
   flip=sign( rand(size(diffdata))-.5);
    perm_data = diffdata .* flip;
    
    TS_perm = zeros(1,length(time2));
    PS_perm = zeros(1,length(time2));
    
    for t = 1:length(time2)
        [~,PS_perm(t),~,stats] = ttest(perm_data(:,t));
        TS_perm(t) = stats.tstat;
    end
    
    % threshold
    clusters_perm = PS_perm < 0.05;
    
    % find clusters
    cs = find(diff([0 clusters_perm]) == 1);
    ce = find(diff([clusters_perm 0]) == -1);
    
    if isempty(cs)
        max_cluster_mass_perm(p) = 0;
    else
        tmp_mass = zeros(1,length(cs));
        for c = 1:length(cs)
            idx = cs(c):ce(c);
            tmp_mass(c) = sum(abs(TS_perm(idx)));
        end
        max_cluster_mass_perm(p) = max(tmp_mass);
    end
end




cluster_pvals = zeros(1,nClusters);

for c = 1:nClusters
    cluster_pvals(c) = mean(max_cluster_mass_perm >= cluster_mass(c));
end
sig_clusters = find(cluster_pvals < 0.05);
ax=axis;
for c = sig_clusters
    fprintf('Cluster %d significant from %d to %d (p=%.4f)\n', ...
        c, cluster_starts(c), cluster_ends(c), cluster_pvals(c));
    % plot significant clusters
plot([time2(cluster_starts(c)), time2(cluster_ends(c))],ones(1,2)*ax(4)-10,'r-','LineWidth',4)
end



%%

% BIN FOR ANOVA
nBins = 32;
[nSub, nTime] = size(BG_EFFECT_R);

%binEdges = round(linspace(1, nTime+1, nBins+1)); % edges of bins
bins = ceil( ((1:nTime)/nTime)*nBins);
binR = zeros(nSub, nBins);
binO = zeros(nSub, nBins);

for b = 1:nBins
    idx = find(bins==b);
    binR(:,b) = mean(BG_EFFECT_R(:,idx),2);
    binO(:,b) = mean(BG_EFFECT_O(:,idx),2);
end

Y = [binR(:); binO(:)];             % dependent variable

dd=binR-binO;
[~,p]=ttest(dd);
[reject, adj_pvals] = holmBonferroni(p,0.05)
TimeBin = repmat(1:nBins, nSub, 2);      % subjects × bins × backgrounds
TimeBin = TimeBin(:);
Background = [ones(nSub*nBins,1); 2*ones(nSub*nBins,1)];  % 1=R, 2=O

Subjects = repmat((1:nSub)', nBins*2,1);
tbl = table(Y,TimeBin,Background,Subjects);

stats = rm_anova2(Y,Subjects,TimeBin,Background,{'time','background'});


nBackgrounds = 2;  % R and O
tblData = [binR binO];

varNames = cell(1, nBins*nBackgrounds);
for b = 1:nBins
    varNames{b} = sprintf('R_bin%d',b);
    varNames{b+nBins} = sprintf('O_bin%d',b);
end

tbl = array2table(tblData,'VariableNames',varNames);

% add subject ID as first column
tbl.Subject = (1:nSub)';

% reorder columns so Subject is first
tbl = tbl(:,[end 1:end-1]);

writetable(tbl,'BG_binned_for_JASP.csv');

% compute behavior

% plot standard matches plot
figure
sty={'-','--'};
mMATCHES=mean(MATCHES_ALL,3);
seMATCHES=std(MATCHES_ALL,0,3)/sqrt(size(MATCHES_ALL,3));
% put into candelas
mMATCHES=sum(monxyY(:,3))*mMATCHES;
seMATCHES=sum(monxyY(:,3))*seMATCHES;
for rot=1:2
   hleg(rot)= errorbar(1:2,mMATCHES(:,rot),seMATCHES(:,rot),['k' sty{rot}],'LineWidth',3);
    hold on
end
box off
ylabel('lightness match (cd/m^{2})','FontSize',20)
axis square
set(gca,'LineWidth',3,'FontSize',20,'XTick',1:2,'XTickLabel',{'Dark','Light'})
legend(hleg,{'upright','rotated'});
legend boxoff
xlim([.5 2.5])


% Preallocate
Participant = [];
DV = [];
Background = [];
Rotation = [];

% Loop through all combinations to create long table
for p = 1:size(MATCHES_ALL,3)
    for b = 1:2
        for r = 1:2
            Participant(end+1,1) = p;                          % participant ID
            DV(end+1,1) = MATCHES_ALL(b,r,p);                 % dependent variable
            Background(end+1,1) = b;                           % 1=Dark, 2=Light
            Rotation(end+1,1) = r;     
        end
    end
end

% Create table
tbl = table(Participant, DV, Background, Rotation);
rm_anova2(DV,Participant,Background,Rotation,{'background','rotation'})

% Get dimensions
[nBackgrounds, nRotations, nParticipants] = size(MATCHES_ALL);

% Create column names for JASP
colNames = cell(nBackgrounds*nRotations,1);
cnt = 1;
bgNames = {'Dark','Light'};
rotNames = {'upright','rotated'};
for b = 1:nBackgrounds
    for r = 1:nRotations
        colNames{cnt} = [bgNames{b} '_' rotNames{r}];
        cnt = cnt + 1;
    end
end

%% Pairwise post-hoc comparisons

[nBackgrounds, nRotations, nParticipants] = size(MATCHES_ALL);

bgNames  = {'Dark','Light'};
rotNames = {'upright','rotated'};

% Put the four conditions into participants x conditions
X = nan(nParticipants, nBackgrounds*nRotations);
condNames = cell(1,nBackgrounds*nRotations);

cnt = 1;
for b = 1:nBackgrounds
    for r = 1:nRotations
        X(:,cnt) = squeeze(MATCHES_ALL(b,r,:));
        condNames{cnt} = [bgNames{b} '_' rotNames{r}];
        cnt = cnt + 1;
    end
end

% All six pairwise comparisons
pairs = nchoosek(1:size(X,2),2);
nComp = size(pairs,1);

p_raw  = nan(nComp,1);
tval   = nan(nComp,1);
df     = nan(nComp,1);
dz     = nan(nComp,1);
meanDiff = nan(nComp,1);
CI_low = nan(nComp,1);
CI_high = nan(nComp,1);

for k = 1:nComp

    x1 = X(:,pairs(k,1));
    x2 = X(:,pairs(k,2));

    % Paired t test
    [~,p_raw(k),ci,stats] = ttest(x1,x2);

    d = x1 - x2;

    tval(k) = stats.tstat;
    df(k) = stats.df;
    meanDiff(k) = mean(d,'omitnan');

    % Cohen's dz for paired observations
    dz(k) = mean(d,'omitnan') / std(d,'omitnan');

    CI_low(k) = ci(1);
    CI_high(k) = ci(2);
end


% Holm correction for multiple comparisons

[p_sorted,idx] = sort(p_raw);
m = length(p_raw);

p_holm_sorted = nan(m,1);

for i = 1:m
    p_holm_sorted(i) = (m-i+1) * p_sorted(i);
end

% Enforce monotonicity
for i = 2:m
    p_holm_sorted(i) = max(p_holm_sorted(i),p_holm_sorted(i-1));
end

p_holm_sorted = min(p_holm_sorted,1);

p_holm = nan(m,1);
p_holm(idx) = p_holm_sorted;


% Results table

Comparison1 = condNames(pairs(:,1))';
Comparison2 = condNames(pairs(:,2))';

posthoc_tbl = table(Comparison1, Comparison2, meanDiff, ...
    tval, df, p_raw, p_holm, dz, CI_low, CI_high);

disp(posthoc_tbl)
%%
% Preallocate wide table
wideData = zeros(nParticipants, nBackgrounds*nRotations);

% Fill table
for p = 1:nParticipants
    cnt = 1;
    for b = 1:nBackgrounds
        for r = 1:nRotations
            wideData(p,cnt) = MATCHES_ALL(b,r,p);
            cnt = cnt + 1;
        end
    end
end

% Convert to table
tbl_wide = array2table(wideData, 'VariableNames', colNames);

% Optional: add participant ID column
tbl_wide.Participant = (1:nParticipants)';

% Reorder to have Participant first
tbl_wide = movevars(tbl_wide, 'Participant', 'Before', 1);

% Save for JASP
writetable(tbl_wide, 'anova_table_behavior.csv');

% correlate effect size with pupil

% individual rotation effect
mdd=mean(dd);
maxpos=find(mdd==max(mdd));
individual_pupil_rot_effect=dd(:,maxpos);

% compute behavior

BACKGROUND_EFF_ALL =squeeze(MATCHES_ALL(1,:,:)-MATCHES_ALL(2,:,:));
ROT_EFFECT_ON_BG=BACKGROUND_EFF_ALL(1,:)-BACKGROUND_EFF_ALL(2,:);
figure
plot(ROT_EFFECT_ON_BG,individual_pupil_rot_effect,'ko')
[r pcor]=corr(ROT_EFFECT_ON_BG',individual_pupil_rot_effect)

