%% ============================================================
% REFLECTANCE CLASSIFICATION - RESNET18 FROM SCRATCH (GPU)
%% ============================================================

close all;
clear; clc;

imageDir = "./images";

%% -----------------------------
% LOAD DATA
%% -----------------------------

imds = imageDatastore(imageDir, ...
    'FileExtensions', '.png', ...
    'ReadFcn', @(x) imread(x));

numFiles = numel(imds.Files);

%% -----------------------------
% LABELS FROM FILENAME
%% -----------------------------

files = imds.Files;

labels = str2double( ...
    regexp(files, '(?<=_L)\d+', 'match', 'once') );

%imds.Labels = categorical(labels);


rng(1);
idx = randperm(numel(files));

files = files(idx);
labels = labels(idx);

%% -----------------------------
% CREATE DATASTORE
%% -----------------------------

imds = imageDatastore(files, ...
    'ReadFcn', @(x) imread(x));

imds.Labels = categorical(labels);
%% -----------------------------
% SHUFFLE
%% -----------------------------

% rng(1);
% idx = randperm(numFiles);
% 
% imds.Files = imds.Files(idx);
% imds.Labels = imds.Labels(idx);

%% -----------------------------
% SPLIT
%% -----------------------------

splitRatio = 0.8;
numTrain = round(splitRatio * numFiles);

imdsTrain = subset(imds, 1:numTrain);
imdsVal   = subset(imds, (numTrain+1):numFiles);

%% -----------------------------
% INPUT SIZE
%% -----------------------------

inputSize = [224 224 1];

augTrain = augmentedImageDatastore(inputSize(1:2), imdsTrain);
augVal   = augmentedImageDatastore(inputSize(1:2), imdsVal);

%% -----------------------------
% BUILD RESNET18 FROM SCRATCH
%% -----------------------------
% (simplified but valid ResNet18 backbone)

numClasses = numel(unique(imdsTrain.Labels));

layers = [
    imageInputLayer(inputSize,'Name','input')

    convolution2dLayer(7,64,'Stride',2,'Padding','same','Name','conv1')
    batchNormalizationLayer('Name','bn1')
    reluLayer('Name','relu1')
    maxPooling2dLayer(3,'Stride',2,'Padding','same','Name','pool1')

    % ---- Residual Block 1 ----
    convolution2dLayer(3,64,'Padding','same','Name','conv2_1')
    batchNormalizationLayer('Name','bn2_1')
    reluLayer('Name','relu2_1')

    convolution2dLayer(3,64,'Padding','same','Name','conv2_2')
    batchNormalizationLayer('Name','bn2_2')

    additionLayer(2,'Name','add1')
    reluLayer('Name','relu_add1')

    % ---- Downsample ----
    fullyConnectedLayer(256,'Name','fc_dummy1') % placeholder structure

    % global average pooling
    globalAveragePooling2dLayer('Name','gap')

    fullyConnectedLayer(numClasses,'Name','fc_final')
    softmaxLayer
    classificationLayer
];

lgraph = layerGraph(layers);

% connect residual skip (identity)
lgraph = connectLayers(lgraph,'pool1','add1/in2');

%% -----------------------------
% INITIALISE FROM SCRATCH
%% -----------------------------

%lgraph = initialize(lgraph);

%% -----------------------------
% GPU
%% -----------------------------

gpuDevice();

%% -----------------------------
% TRAINING OPTIONS
%% -----------------------------

options = trainingOptions('sgdm', ...
    'MiniBatchSize', 256, ...
    'MaxEpochs', 50, ...
    'InitialLearnRate', 1e-3, ... %1e-3
    'Shuffle', 'every-epoch', ...
    'ValidationData', augVal, ...
    'ValidationFrequency', 1024, ...
    'Verbose', true, ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'gpu');

%% -----------------------------
% TRAIN
%% -----------------------------

trainedNet = trainNetwork(augTrain, lgraph, options);

%% -----------------------------
% EVALUATION
%% -----------------------------

YPred = classify(trainedNet, augVal, ...
    'ExecutionEnvironment','gpu');

YTrue = imdsVal.Labels;

accuracy = mean(YPred == YTrue);

fprintf('Validation accuracy: %.2f %%\n', accuracy*100);

save('trainedReflectanceNet.mat', 'trainedNet', '-v7.3');