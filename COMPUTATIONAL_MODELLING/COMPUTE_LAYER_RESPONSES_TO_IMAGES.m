clear all
close all

% -----------------------------
% LOAD TRAINED NETWORK
% -----------------------------

load('trainedReflectanceNet.mat', 'trainedNet');
% -----------------------------
% IMAGE DATASET
% -----------------------------

imageDir = "./images";

imds = imageDatastore(imageDir, ...
    'FileExtensions', '.png', ...
    'ReadFcn', @(x) imread(x));

% -----------------------------
% NETWORK INPUT SIZE
% -----------------------------

inputSize = trainedNet.Layers(1).InputSize;

% -----------------------------
% RESIZE DATASTORE
% -----------------------------

augImds = augmentedImageDatastore( ...
    inputSize(1:2), ...
    imds);

% -----------------------------
% GET ALL LAYER NAMES
% -----------------------------

layerNames = string({trainedNet.Layers.Name});

% -----------------------------
% OUTPUT FOLDER
% -----------------------------

outDir = "./layer_responses";

if ~exist(outDir,'dir')
    mkdir(outDir);
end

% -----------------------------
% GPU
% -----------------------------

gpuDevice;

% ============================================================
% EXTRACT ACTIVATIONS LAYER BY LAYER
% ============================================================

for i = 1:numel(layerNames)

    layerName = layerNames(i);

    fprintf('\n====================================\n');
    fprintf('Layer %d / %d : %s\n', ...
        i, numel(layerNames), layerName);
    fprintf('====================================\n');

    try

        % -----------------------------------------
        % activations:
        % rows = images
        % cols = features
        % -----------------------------------------

        A = activations( ...
            trainedNet, ...
            augImds, ...
            layerName, ...
            'OutputAs', 'rows', ...
            'ExecutionEnvironment', 'gpu');
% compute sim mat
dissimmat=nan(size(A,1),size(A,1));
allcombs=nchoosek(1:size(A,1),2);
% for ccom=1:size(allcombs,1)
%     p1=allcombs(ccom,1);
%     p2=allcombs(ccom,2);
%     v1=A(p1,:);
%     v2=A(p2,:);
%  %sqrt(sum( (v1-v2).^2  ))
% di=norm(v1-v2);
% dissimmat(p1,p2)=di;
% end
%D = pdist(A,'euclidean');

AA = sum(A.^2,2);

D2 = AA + AA' - 2*(A*A');

D2(D2<0) = 0; % numerical safety
D = sqrt(D2);
        % -----------------------------------------
        % save
        % -----------------------------------------

        outFile = fullfile(outDir, ...
            sprintf('%s.mat', layerName));

        save(outFile, ...
            'D', ...
            'layerName', ...
            '-v7.3');

        fprintf('Saved: %s\n', outFile);

    catch ME

        fprintf('Skipped layer: %s\n', layerName);
        fprintf('Reason: %s\n', ME.message);

    end

end

fprintf('\nDONE.\n');