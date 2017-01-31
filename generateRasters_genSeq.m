function generateRasters_genSeq(signals,TrialIndx,ExpStruct,baseline,triggerSweep,useROIs,zscoreit)
%sequence opt = 1 - all ROIs in order duing each sweep
if ~exist('useROIs')
    useROIs=length(signals.rois)-1;
end
if ~exist('zscoreit')
    zscoreit=0;
end

offset=0; %seconds

fn=fieldnames(TrialIndx);


coloraxis=[-2 2];

smofactor=10;
FPS=30;
%initialize color vector = assume that control always comes first in bl;ac
c{1}='k';
c{2}='r';
c{3}='m';
c{4}='b';
c{5}='m';


%baseline is 0 if you want to leave unpertrubed, if it is entered it should
%be number of frames
if ~exist('baseline')
    baseline=0;
end;



if baseline ~=0;
    baseline=1:baseline;
end


%for each ROI
for Q = 1:numel(useROIs);  %dont plot last Roi....
    clear traces ts SEM toPlot CI ts;
    n=useROIs(Q);
    
      n
    figure()
   
    % fo each condition
    for j = 1:numel(fn)
        subplot(1,numel(fn),j)
        %extract traces
        traces=(signals.rois(n).dFF(TrialIndx.(fn{j}),:));
        
        %create time vector
        t=[1:length(traces)]/FPS;
        
        %if we're baselining, apply bl correction
        if baseline~=0;
            traces=bsxfun(@minus,traces,mean(traces(:,baseline),2));
        end
        
        %smooth traces
        traces=smoothrows(traces,smofactor);
         
        if zscoreit
        imagesc(zscore(traces,[],2))
        else
        imagesc(traces)
        end
        
     
            y=ylim;

    
    % figure out where hologram is on and patch!
   
    axis square
    axis off
    title(fn{j})
    
    cax(:,j)=caxis;
    
    end
   
    if ~exist('coloraxis')
    mc=max(cax(1,:));
    mac=min(cax(2,:));
    for j = 1:numel(fn)
        subplot(1,numel(fn),j)
        caxis([mc mac  ]);
    end
    
    
    colormap(b2r(mc,mac))
    else
    colormap(b2r(coloraxis(1),coloraxis(2)))
    end
    waitforbuttonpress
    close all
  
    
    
end