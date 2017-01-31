function stimtimes=findStimTime(rois,ExpStruct,triggersweep);

s=ExpStruct.stims{triggersweep}{4};
onset = find(diff(s)>0);
offset = find(diff(s)<0);

if numel(ExpStruct.Holo.holoRequests{1}.Sequence{1}) ~= numel(onset);
    errordlg('Number of pulses is not equal to number of holograms in the sequence')
end;

seq=ExpStruct.Holo.holoRequests{1}.Sequence{1};

ExpStruct.Holo.holoRequests{1}.rois{1};
roiComposition=ExpStruct.Holo.holoRequests{1}.rois;

for r=1:numel(rois);  %for each ROI;

    for n=1:length(seq);  %go through the whole seuqence
        thisHolo=seq(n);  % extract the holos on at N time

        ROIs=roiComposition{thisHolo}; % figure out which ROI compose the hologram

        if ~isempty(intersect(r,ROIs))  %if the intersect with the ROI we carea bout isent empty..
            stimtimes(r,1)=onset(n);
            stimtimes(r,2)=offset(n);
        end
    end
end

stimtimes=stimtimes/2000;