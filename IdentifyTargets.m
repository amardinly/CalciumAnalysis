function [targetROI, targetDistance] = IdentifyTargets(ROIinfo,signals,plotopt)
%function takes either a path to an ROI file or ROIdata directly and
%the signals output from extract signals and returns a list of ROI
%indexes that are closest to the targets stimulated in ROIdata as well
%as the euclidean distance.
if nargin<3;
    plotopt=0;
end

if isstruct(ROIinfo)
    ROIdata = ROIinfo;
elseif exist(ROIinfo)
    load(ROIinfo,'-mat');
else
    fprintf('ROI file not found or not correct');
    return
end

targetDepths = [ROIdata.rois.depth];%get depths from ROIdata
numTarget = numel(targetDepths);  %how many targets
for j=1:numel(ROIdata.rois); %unpack centroids from ROIdata
targetCentroid(j,:) = ROIdata.rois(j).centroid;
end
targetLoc = cat(2,targetCentroid,targetDepths');  %cat centroid and depths for 3 term loc vector

ROIloc =[];
for i = 1:numel([signals.Depths])  %for each depth

    for r = 1:size(signals(i).Depths.ROIs,3)  %for each ROI circles in sbxflood
    
        try
            loc = [centerOfMass(double(signals(i).Depths.ROIs(:,:,r))) i];
            locR=loc([2 1 3]);
         
            
            ROIloc = cat(1,ROIloc,locR);
        catch %catch is for ROIs that have no pixels assigned to them, and are entirely nans. this can happen sometimes in sbxflood
            ROIloc = cat(1,ROIloc,[0 0 1]);
       
        end
    end
end




roiDistance=[];
for i = 1:size(targetLoc,1)  %for each target
    d = targetLoc(i,3); %depth
    for r = 1:size(ROIloc,1)  %for each ROI
        if d==ROIloc(r,3)
            roiDistance(i,r) = sqrt(sum((targetLoc(i,1:2)-ROIloc(r,1:2)).^2));
        else
            roiDistance(i,r) = NaN;
        end
    end
end

[targetDistance, targetROI] = min(roiDistance,[],2);


if plotopt
    for j=1:numel(signals)
        
        subplot(1,numel(signals),j)
        
        imagesc(uint8(sum(signals(1).Depths.ROIs,3)))
        
        hold on
        
        indx=find(targetLoc(:,3)==j);
        ROIs=targetROI(indx);
        scatter(ROIloc(ROIs,1),ROIloc(ROIs,2),'r')
        
        axis square; axis off;
        for n=1:numel(ROIdata.rois)
            if ROIdata.rois(n).depth==j;
                hold on
                plot(ROIdata.rois(n).vertices(:,1),ROIdata.rois(n).vertices(:,2),'m')
            end
            
            
        end
    end
end