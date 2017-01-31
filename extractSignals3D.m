function signals=extractSignals3D(expName,alignfile,segmentfile,daqfile,FPT,filedir,rect,includeTifs);
%% Attempt at average movie
%clear all; close all force;
%expName='ExpA_20160824.mat';

disp('Loading Align file')
load(alignfile,'-mat');
disp('Loading Segment File')
load(segmentfile,'-mat');
disp('Loading DAQ file')
load(daqfile);
close all force;
hCellVersion=1;  %or 2

%FPT=390;
k=filedir;  %('Z:\amardinly\Imaging\5390\20160824\FOV1\')  ;%path to actual movies
savename=[filedir expName '.mat'];


%ROIdata=ExpStruct.Holo.ROIdata;
%save('FOV1_Rois','ROIdata')
%ROIanalysis
%rect=[38 4 431 503];
disp('Extractin ROIs and neuropil')
if ~exist('ROIs')
ROIs = makeROI(mask,dim,rect);
end


%imagesc(sum(ROIs,3))

%if stimROIs
%[ROIs] = orderROIs(ROIs,ExpStruct);
%else
%[ROIs] = killStimROIs(ROIs,ExpStruct);    
%end

[NPM] = createNPmask(ROIs,rect);
%last ROI is goin to be a strip on the left to catch stim artifacts to help
%fight off by n errors!



%disp('added align ROI')
%s=size(ROIs,3);
%for j=1:5
%ROIs(:,:,s+j)=zeros([size(ROIs,1) size(ROIs,2)]);
%ROIs(1:512,((100*j)-99):(100*j),s+j)=1;
%NPM(:,:,s+j)=zeros([size(ROIs,1) size(ROIs,2)]);
%end;

%%
disp('Processing Signals')

[signals]= extractSignals4(ROIs,NPM,k,FPT,T,includeTifs);


pq=1; roiDel=[];
%assign red value to ROIs
for j=1:numel(signals.rois);
    
    signals.rois(j).redvalue=mean(signals.rois(j).redSweeps(:));
    
    a=bwconncomp(ROIs(:,:,j));
    r=regionprops(a);
    
    if isempty(a.PixelIdxList)
        roiDel(pq)=j;
        pq=pq+1;
        signals.rois(j).centroid=0;
    signals.rois(j).area=0;
    else
        
    
    signals.rois(j).centroid=r.Centroid;
    signals.rois(j).area=r.Area;
    
    end
end;

signals.rois(roiDel)=[];

save(savename);
save(savename,'ROIs','-append');
save(savename,'k','-append');
save(savename,'FPT','-append');
save(savename,'T','-append');
save(savename,'rect','-append');


