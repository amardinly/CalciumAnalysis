%% Analysis 2016 08 29 FOV1

%clear all; close all; clc;
%Cluster1_MC('Z:\amardinly\Imaging\5390\20160824\FOV1\',1,162)


k='Z:\amardinly\Imaging\5390\20160824\FOV1\';

signals=extractSignals('FOV1_20160824','FOV1_loc_001-162.align','FOV1_loc_001-162.segment','160824_A.mat',390,k,[1 1 511 511],1:161);

clear all;
load('160824_A.mat')
load('FOV1_20160824.mat')

ntrials=161;
stimNames=ExpStruct.output_names(unique(ExpStruct.stim_tag(1:ntrials)));
%note: looks like daq didnt complete on last trial
%also looks like we never ran the control sweeps


%% Pick ROI for stims

for n =1:10
imagesc(signals.meanRed(:,:,n))
pause(1)
end

imagesc(signals.meanRed(:,:,2))
r=getrect()

trialROIw1=round(r(1):r(1)+r(3));
trialROIh1=round(r(2):r(2)+r(4));

meanArtifcat=squeeze(mean(mean(signals.meanRed(trialROIh1,trialROIw1,:))));

plot(meanArtifact,'o')

clear TrialIndx;
% Extract Trial Indices
TrialIndx.Control=find(meanArtifcat<=305);
TrialIndx.MW100=find(meanArtifcat>600);
TrialIndx.MW25=find((meanArtifcat>305) & (meanArtifcat<600));

%%  Get data on the stimulatin
[stimROIs stimtimes]=getStimStructure(ExpStruct,5);
%% extract dff
signals=computeDFF(signals,'prcnt',1);

%% Check for  global changes in flour
for n = 1:numel(signals.rois);
    imagesc(signals.rois(n).sweeps)
    pause(0.5)
end
%%
for n = 1:numel(signals.rois);
f(n,:)=(mean(signals.rois(n).sweeps,2));
end
imagesc(zscore(f,[],2))
caxis([-5 5])

figure()
plot(zscore(f',[],2))
%% Generate plots
%plot individual ROIs
BL=1:30;
nrois=1:numel(signals.rois);
triggerSweep=5;

generatePlots_genSeq(signals,TrialIndx,ExpStruct,BL,triggerSweep,nrois,stimtimes)
generateRasters_genSeq(signals,TrialIndx,ExpStruct,BL,triggerSweep,nrois,1)

L=summaryRasters(signals,TrialIndx.MW100,TrialIndx.Control);

 
 
 
%% Get Data
distanceResponse(signals,stimROIs,ROIs,TrialIndx.MW100,BL)

redResponse(signals,stimROIs,ROIs,TrialIndx.MW100,50,BL)

map_responses(stimROIs,signals,TrialIndx.MW100,ROIs,BL);

dFFmovie(stimROIs,signals,TrialIndx.MW100,TrialIndx.Control,ROIs,BL);

%% moives

[AvgImg AvgDffmovie]=makeAvgMovie(k,T,TrialIndx.MW100,390,1:30);
save('AvgStimMovie.mat','AvgImg','AvgDffmovie')
showMovie(AvgDffmovie,stimROIs,[-1.5 3]);
showMovie(AvgImg,stimROIs,[0 150]);