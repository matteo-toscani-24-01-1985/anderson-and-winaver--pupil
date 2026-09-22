%% ============================================================
% REFLECTANCE CLASSIFICATION - RESNET18 FROM SCRATCH (GPU)
%% ============================================================

close all;
clear; %clc;

imageDir = "./images";
%imageDir = "./images_rotated";

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


gpuDevice();

%% -----------------------------
% TRAINING OPTIONS
%% -----------------------------


load('trainedReflectanceNet.mat', 'trainedNet');
%% -----------------------------
% EVALUATION
%% -----------------------------

YPred = classify(trainedNet, augVal, ...
    'ExecutionEnvironment','gpu');

YTrue = imdsVal.Labels;

accuracy = mean(YPred == YTrue);

fprintf('Validation accuracy: %.2f %%\n', accuracy*100);

