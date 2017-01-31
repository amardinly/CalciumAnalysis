function dFFmovie(stimROIs,signals,TrialIndxStim,TrialIndxCon,ROIs,BL,HR,ca,savename)
if ~exist('ca'); ca=[-1 1]; end;
global ExpStruct
if isempty(TrialIndxCon); subtractControl=0; else;subtractControl=1; end;

if exist('savename')
    save=1;
else
    save=0;  %write save functions
end

if save
    vw=VideoWriter([savename '.avi'],'Motion JPEG AVI');
    open(vw);
end;

   seq=ExpStruct.Holo.holoRequests{HR}.Sequence{1};
    
FPS=30;
img=zeros(512,512,length(signals.rois(1).dFF));

for j=1:numel(signals.rois); % each ROI
    disp(['processing ROI ' num2str(j)])
    traces=(signals.rois(j).dFF(TrialIndxStim,:));
    %  traces=(signals.rois(j).sweeps(TrialIndxStim,:));
    
    traces=bsxfun(@minus,traces,mean(traces(:,BL),2));
    traces=smoothrows(traces,10);
    traces=mean(traces);
    if subtractControl
        ctraces=(signals.rois(j).dFF(TrialIndxCon,:));
        %  traces=(signals.rois(j).sweeps(TrialIndxStim,:));
        
        ctraces=bsxfun(@minus,ctraces,mean(ctraces(:,BL),2));
        ctraces=smoothrows(ctraces,10);
        ctraces=mean(ctraces);
        
        
        
        
        for n=1:size(signals.rois(1).dFF,2)
            img(:,:,n)=img(:,:,n)+(ROIs(:,:,j)*(traces(n)-ctraces(n)));
        end
    else
        for n=1:length(signals.rois(1).dFF)
            img(:,:,n)=img(:,:,n)+(ROIs(:,:,j)*(traces(n)));
        end
        
    end
    
end

disp('extraction stimulation coordinates')
    for n = 1:numel(stimROIs)
        stim(n,1)=seq(n);
        stim(n,2)=round(stimROIs(n).stimsOn*FPS);
        stim(n,3)=round(stimROIs(n).stimsOff*FPS);
        
    end



fig=figure();
on=0;
for f = 1:length(signals.rois(1).dFF(1,:));
    
    

    if ~isempty(intersect(f,stim(:,2)));
        on=1;
        [x b p]=intersect(f,stim(:,2));
        currentROI=stim(p,1);
    elseif ~isempty(intersect(f,stim(:,3)));
        on = 0;
        
    end
    imagesc(img(:,:,f))
    colormap(b2r(ca(1),ca(2)))
    %colormap gray
    %caxis([-25 25])
    axis off
    axis square
    hold on
    
    if on
       for vj=1:numel(stimROIs(p).rois)
        plot(stimROIs(p).rois(vj).vert(:,1),stimROIs(p).rois(vj).vert(:,2),'color',[.5 .5 .5],'LineWidth',1);
       end
    
    end
    
    hold off
    pause(0.03)
    
    if save
        h=getframe(fig);
        writeVideo(vw,h.cdata);
    end
    
    
end

if save;
    close(vw);
end;
