function [stimROIs stimtimes]=getStimStructure(ExpStruct,triggersweep,hrn,multiholo);

FPS=30;
if ~exist('hrn'); hrn=1; end;
for n = 1:numel(ExpStruct.Holo.ROIdata.rois);
    theseROIs(n).mask=ExpStruct.Holo.ROIdata.rois(n).mask;
    theseROIs(n).centroid=ExpStruct.Holo.ROIdata.rois(n).centroid;
    theseROIs(n).vert=ExpStruct.Holo.ROIdata.rois(n).vertices;
end

if ~exist('multiholo'); multiholo=0; end;




s=ExpStruct.stims{triggersweep}{7};
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
        thisHolo=seq(n);  % extract the holos on at N time        
        ROIs=roiComposition{thisHolo}; % figure out which ROI compose the hologram
        
        clear timeOn timeOff
%         
%         timeOn=change(n);
%         
%         if n~=length(seq);
%             timeOff=change(n+1);
%         else
%             timeOff=length(ExpStruct.stims{triggersweep}{4})/2000;
%         end
%             
        
        try
            
            [a b c]=intersect(thisHolo,seq);
            
            stimtimes(n,1)=onset(c);
            
            stimROIs(n).stimsOn=onset(c);
 
            if n~=length(seq);
                stimtimes(n,2)=onset(c+1)-(1/FPS);
                stimROIs(n).stimsOff=offset(c+1)-(1/FPS);
            else
                stimtimes(n,2)=onset(c)+(onset(c)-onset(c-1));
                stimROIs(n).stimsOff=onset(c)+(onset(c)-onset(c-1));
                
            end
            
        end
            for r=1:length(roiComposition(ROIs))
            stimROIs(n).rois(r)=theseROIs(ROIs(r));
            end
             
        
        
        
        
            
%             errordlg('could not find ROI');
%             stimtimes(r,1)=0;
%             stimtimes(r,2)=0;
%             
%             stimROIs(r).stimsOn=[];
%             stimROIs(r).stimsOff=[];
%             
        end
end
    