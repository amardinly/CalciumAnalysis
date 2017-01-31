function map_responses(stimROIs,signals,TrialIndxStim,ROIs,BL,HR,ca)
if ~exist('ca'); ca=[-1 1]; end;
global ExpStruct
FPS=30;
shift=4;
for n =1:numel(signals.rois)
    signals.rois(n).dFF(TrialIndxStim)=smoothrows(signals.rois(n).dFF(TrialIndxStim),10);
end

for n = 1:numel(stimROIs)
    
    seq=ExpStruct.Holo.holoRequests{HR}.Sequence{1};
    currentROI=seq(n);
    
    
    img=zeros(512,512);
    t=round(stimROIs(n).stimsOn*FPS)+shift:round(stimROIs(n).stimsOff*FPS)+shift;
    for j=1:numel(signals.rois); % each ROI
        
        
        if exist('BL')
            base = mean(mean(signals.rois(j).dFF(TrialIndxStim,BL)));
        else
            base=0;
        end
        
        resp = mean(mean(signals.rois(j).dFF(TrialIndxStim,t)));
        
        
        img=img+(ROIs(:,:,j)*((resp-base)));
        
        hold on
        
    end
    
    figure()
    imagesc(img)
    %colormap parula
    colormap(b2r(ca(1),ca(2)))
    %  caxis([-.5 .5])
    axis off
    axis square
    hold on
    
    for vj=1:numel(stimROIs(n).rois)
        plot(stimROIs(n).rois(vj).vert(:,1),stimROIs(n).rois(vj).vert(:,2),'color',[.6 .6 .6],'LineWidth',1);
    end
    
    
    waitforbuttonpress
    close all
    
end
