clear all
close all

% EXPERIMENT 2: PAPER ANALYSIS
% Aggregates participant data, generates the behavioral plot used in the
% paper, exports the repeated-measures table, and runs the factorial ANOVA.

files = dir(fullfile('.', 'DATA', '*.csv'));

for s = 1:numel(files)
    MEANS(:,:,:,s) = ANALYSE(files(s).name);
end

% Express transformed response values on a 0-100 scale, as in the figure.
MEANS = MEANS * 100;

mMEANS  = mean(MEANS, 4, 'omitnan');
seMEANS = std(MEANS, 0, 4, 'omitnan') / sqrt(numel(files));

% Actual presentation durations used by the experiment.
timingTable = readtable(fullfile('.', 'pavlovia', 'moon_timing', ...
                                'TABLE_CONDITIONS.xlsx'));
times = unique(timingTable.DURATION);

%% Figure 3A: lightness matches across presentation duration

figure

lineStyles = {'-','--'};
cols = {'r','b'};

% Small offsets in log10 units prevent overlapping error bars.
% Configuration 1 has the larger offset; configuration 2 the smaller one.
gaps = [0.06 0.03];

for rot = 1:2
    for bg = 1:2

        logx = log10(times);
        logx = logx + sign(bg - 1.5) * gaps(rot);
        x = 10.^logx;

        errorbar(x, ...
                 mMEANS(:,bg,rot), ...
                 seMEANS(:,bg,rot), ...
                 ['ko' lineStyles{rot}], ...
                 'Color', cols{bg}, ...
                 'LineWidth', 3);
        hold on

        plot(x, ...
             mMEANS(:,bg,rot), ...
             'ko', ...
             'Color', cols{bg}, ...
             'MarkerSize', 13, ...
             'MarkerFaceColor', cols{bg});
    end
end

set(gca, ...
    'XScale', 'log', ...
    'LineWidth', 3, ...
    'FontSize', 20, ...
    'XMinorTick', 'off');

box off
axis square

xlabel('Time (ms)', 'FontSize', 20);
ylabel('Lightness Match', 'FontSize', 20);

ylim([20 40]);
xlim([40 2350]);

xticks(times);
xticklabels(round(times));

%% Repeated-measures analysis

nSubj = size(MEANS,4);

% MATLAB factorial repeated-measures analysis.
rm_anova_nd(MEANS, {'time','background','rotation'});

% Export the same participant-by-condition data in wide format for JASP.
T = table;
T.Subject = (1:nSubj)';

for rot = 1:2
    for bg = 1:2
        for ti = 1:numel(times)

            vname = sprintf('R%d_B%d_T%d', ...
                            rot, bg, round(times(ti)));

            T.(vname) = squeeze(MEANS(ti,bg,rot,:));
        end
    end
end

writetable(T, 'JASP_repeated_measures_table_mask.csv');
