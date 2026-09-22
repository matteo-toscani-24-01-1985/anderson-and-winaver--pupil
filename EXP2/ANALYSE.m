function MEANS = ANALYSE(filename)
% ANALYSE_PARTICIPANT_EXP2
% Extract mean lightness matches for one participant in Experiment 2.
%
% Output dimensions:
%   MEANS(duration, background, configuration)
%
% Condition coding follows the stimulus filenames:
%   configuration: 1 = intact, 2 = rotated
%   background:    1/2 as encoded in the stimulus filenames

data = readtable(fullfile('.', 'DATA', filename));

% The first row does not contain a trial response.
DURATIONS = data.DURATION(2:end);

% Convert recorded mouse x-position to one of the 20 response disks.
choicesXtmp = data.mouse_x(2:end);
choicesX = nan(size(choicesXtmp));

for i = 1:numel(choicesXtmp)
    tmp = choicesXtmp{i};
    choicesX(i) = str2double(tmp(2:end-1));
end

xStart = -0.7;
xEnd   =  0.7;

choicesX = ceil(((choicesX - xStart) / (xEnd - xStart)) * 20);
choicesX(choicesX < 1 | choicesX > 20) = NaN;

% Extract configuration and background from stimulus filenames.
images = data.NAME(2:end);
ROTATIONS   = nan(numel(images),1);
BACKGROUNDS = nan(numel(images),1);

for i = 1:numel(images)
    vals = regexp(images{i}, 'r(\d+)b(\d+)s(\d+)', 'tokens');
    ROTATIONS(i)   = str2double(vals{1}{1});
    BACKGROUNDS(i) = str2double(vals{1}{2});
end

uniDUR = unique(DURATIONS);

% Response levels used in the experiment, transformed with gamma = 2.2.
responseLevels = linspace(.2, .8, 20).^2.2;

MEANS = nan(numel(uniDUR), 2, 2);

for rot = 1:2
    for dur = 1:numel(uniDUR)
        for bg = 1:2
            pos = find(ROTATIONS == rot & ...
                       BACKGROUNDS == bg & ...
                       DURATIONS == uniDUR(dur));

            valid = ~isnan(choicesX(pos));
            selected = choicesX(pos(valid));

            MEANS(dur,bg,rot) = mean(responseLevels(selected), 'omitnan');
        end
    end
end
end
