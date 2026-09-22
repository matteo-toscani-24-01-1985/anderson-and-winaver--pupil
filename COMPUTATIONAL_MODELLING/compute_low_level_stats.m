function compute_low_level_stats(img, diskMask, outFile)
% COMPUTE_LOW_LEVEL_STATS
% Extracts simultaneous-contrast style features from one image
%
% INPUTS:
%   img       : H×W grayscale image (double or uint8)
%   diskMask  : logical mask for central disk
%   outFile   : full path to save .mat file
%
% OUTPUT:
%   stats     : 1×7 feature vector
%
% Saves:
%   outFile (MAT file containing stats)

    % -------------------------
    % ensure grayscale double
    % -------------------------
    img = im2double(img);

    if size(img,3) == 3
        img = rgb2gray(img);
    end

    % -------------------------
    % extract regions
    % -------------------------
    disk = img(diskMask);
    bg   = img(~diskMask);

    % -------------------------
    % statistics
    % -------------------------
    diskMean = mean(disk);
    diskStd  = std(disk);

    bgMean = mean(bg);
    bgStd  = std(bg);

    diffMean = diskMean - bgMean;

    michelson = diffMean / (diskMean + bgMean + eps);

    ratio = diskMean / (bgMean + eps);

    % -------------------------
    % feature vector
    % -------------------------
    stats = [diskMean, diskStd, bgMean, bgStd, diffMean, michelson, ratio];

    % -------------------------
    % save to file
    % -------------------------
    if nargin > 2 && ~isempty(outFile)

        if ~exist(fileparts(outFile), 'dir')
            mkdir(fileparts(outFile));
        end

        save(outFile, 'stats');
    end
end