%% Description of run_me
% This script runs model in a bottom-up way
% 1. fit all single models
% 2. determine the best and add one var
% 3. continue until llkd does not increase with adding more variables
clear 
clc
%% make directory
if ~exist('./Results','dir')
    mkdir('./Results')
end

%% parameters %Change Me % 
SampleRate  = 60; % Hz, Data-determined, please don't change for this data
numWorkers  = 10; % maximum number of workers 0 = not parallel
numFolds    = 10; % cross-validation folds
p_threshold = 0.05; % p-value threshold for signrank tests
nboot = 1; % number of bootstrap samples, if = 1 means no bootstrap

%% load the data
% Data is in ./Data folder and contains the behavior variables and 
fprintf('(1/5) Loading data from example session \n')
DataDir = './Data';
date = '161030';
cd(fileparts(mfilename('fullpath')));
FileName = dir(fullfile(DataDir,['*',date,'*']));FileName =fullfile(FileName(1).folder,FileName(1).name);
load(FileName)
[modelType,numModels] = obtain_modelType(numParams);

%% Preparation for saving
i = 1;
saveName = sprintf('%s_run%03d.mat',date,i);
while exist(fullfile('./Results',saveName),'file')~=0
    i = i+1;
    saveName = sprintf('%s_run%03d.mat',date,i);
end

%% Paralellel Setting
if numWorkers~=0 && isempty(gcp('nocreate'))
    parpool('local',numWorkers);
end

%% fit model
fit_ln;
timestamp = datetime('now');
save(fullfile('./Results',saveName),'GLM_out','all_selected_model', 'modelType','timestamp');
