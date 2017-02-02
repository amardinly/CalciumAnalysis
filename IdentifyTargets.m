function [targetROI, targetDistance] = IdentifyTargets(ROIinfo,signals)
%function takes either a path to an ROI file or ROIdata directly and
%the signals output from extract signals and returns a list of ROI
%indexes that are closest to the targets stimulated in ROIdata as well
%as the euclidean distance.


if isstruct(ROIinfo)
    ROIdata = ROIinfo;
elseif exist(ROIinfo)
    load(ROIinfo,'-mat');
else
    fprintf('ROI file not found or not correct');
    return
end

targetDepths = [ROIdata.rois.depth];
numTarget = numel(targetDepths);
targetCentroid = reshape([ROIdata.rois.centroid],[2 numTarget]);
targetLoc = cat(1,targetCentroid,targetDepths);

ROIloc =[];
for i = 1:numel([signals.Depths])
    for r = 1:size(signals(i).Depths.ROIs,3)
        loc = [centerOfMass(double(signals(i).Depths.ROIs(:,:,r))) i];
        ROIloc = cat(2,ROIloc,loc');
    end
end

roiDistance=[];
for i = 1:size(targetLoc,2)
    d = targetLoc(3,i); %depth
    for r = 1:size(ROIloc,2)
        if d==ROIloc(3,r)
            roiDistance(i,r) = sqrt(sum((targetLoc(1:2,i)-ROIloc(1:2,r)).^2));
        else
            roiDistance(i,r) = NaN;
        end
    end
end

[targetDistance, targetROI] = min(roiDistance,[],2);