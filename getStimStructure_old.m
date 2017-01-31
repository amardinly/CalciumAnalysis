function [stimROIs stimtimes]=getStimStructure_old(ExpStruct,triggersweep,hrn,multiholo);
if ~exist('hrn'); hrn=1; end;
for n = 1:numel(ExpStruct.Holo.ROIdata.rois);
    stimROIs(n).mask=ExpStruct.Holo.ROIdata.rois(n).mask;
    stimROIs(n).centroid=ExpStruct.Holo.ROIdata.rois(n).centroid;
    stimROIs(n).vert=ExpStruct.Holo.ROIdata.rois(n).vertices;
end

if ~exist('multiholo'); multiholo=0; end;




s=ExpStruct.stims{triggersweep}{4};
onset = find(diff(s)>0);
offset = find(diff(s)<0);
onset=onset/2000;
offset=offset/2000;

holoChange=(ExpStruct.stims{triggersweep}{7});
change = find(diff(holoChange)>0);
change=change/2000;

if isempty(change);
    holoChange=(ExpStruct.stims{triggersweep}{4});
    change = find(diff(holoChange)>0);
    change=change/2000;
    change(2)=change(length(change));
    change(3:end)=[];
end
    

if numel(ExpStruct.Holo.holoRequests{hrn}.Sequence{1}) ~= numel(change);
    errordlg('Number of pulses is not equal to number of holograms in the sequence')
    
end;

seq=ExpStruct.Holo.holoRequests{hrn}.Sequence{1};
if multiholo; seq=1; end;
ExpStruct.Holo.holoRequests{hrn}.rois{1};
roiComposition=ExpStruct.Holo.holoRequests{hrn}.rois;

    
    for n=1:length(seq);  %go through the whole seuqence
        for r=1:numel(unique(seq));  %for each ROI;

        thisHolo=seq(n);  % extract the holos on at N time
        
        ROIs=roiComposition{r}; % figure out which ROI compose the hologram
        
        clear timeOn timeOff
        
        if seq(n)==ROIs;
            timeOn=change(r);
            
            if r ~= numel(unique(seq)) && ~multiholo;
                timeOff=change(r+1);
            else
                timeOff=length(ExpStruct.stims{triggersweep}{4})/2000;
            end
            
            
            try
                
                onIndx=find(onset>timeOn & onset<timeOff);
                offIndx=find(offset>timeOn & offset<timeOff);
                
                
                
                stimtimes(r,1)=onset(onIndx(1));
                stimtimes(r,2)=offset(offIndx(length(offIndx)));
                
                stimROIs(r).stimsOn=onset(onIndx(1));
                stimROIs(r).stimsOff=offset(offIndx(length(offIndx)));
            catch
                
                errordlg('could not find ROI');
                stimtimes(r,1)=0;
                stimtimes(r,2)=0;
                
                stimROIs(r).stimsOn=[];
                stimROIs(r).stimsOff=[];
                
            end
        end
    end
end