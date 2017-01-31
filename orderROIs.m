function [orROIs NPM] = orderROIs(ROIs,ExpStruct,ROIdata,flag);
%This function is designed to take as an input ROIs that are output by
%Sbxalignment master and register them with targeted regions from a
%biological experiment.  Depending on the flag, it will return all ROIs
%with stim rois in sequence first, or only sequence rois

if ~exist('flag')
    flag=1;   %flag 1 will return only stim rois
end

minOverlap=10;  % min overlap in pixels to register ROI

%seq=ExpStruct.Holo.holoRequests{1}.Sequence{1};
%ro=ExpStruct.Holo.holoRequests{1}.rois;

for n = 1:numel(ExpStruct.Holo.ROIdata.rois)   %for each ROI
    clear score
    
    %extract old roi
    if ~exist('ROIdata')
        oldROI=ExpStruct.Holo.ROIdata.rois(n).pixels;
    else
        oldROI=ROIdata.rois(n).pixels;
    end;
    
    
    
    
    for k=1:size(ROIs,3)  %for each roi
        overlap=(oldROI+ROIs(:,:,k))-1;  %overlap (binary) is the sum of 2 rois minus 1   
        score(k)= sum(overlap(overlap>0));  %score is number of pixels >0
    end;
    [out indx]=sort(score,'descend');
  
    if max(score)>minOverlap
    orROIs(:,:,n)=ROIs(:,:,indx(1));
    
   
    %   ROIs(:,:,indx(1))=[];
    Indxout(n)=indx(1);
    disp(indx(1))
    else
    orROIs(:,:,n)=ExpStruct.Holo.ROIdata.rois(n).pixels;
    disp('Found No Overlap')
    end;
end;

%if flag==1;
%orROIs=cat(3,orROIs,ROIs);
%else