function generateResponseMatrix(signals,TrialIndx,ExpStruct,baseline,stimROIs,useROIs)

%first go through stimRois and calculate the distance to any other ROI
%then find any stim ROI with an ROI <d distance.
%rank in order by proximity







FPS=30;
fex=5;
LW=2;
istart=1;
smofactor=10;



%baseline is 0 if you want to leave unpertrubed, if it is entered it should
%be number of frames
if ~exist('baseline')
    baseline=0;
end;
if baseline ~=0;
    baseline=1:baseline;
end

figure()   
i=1;
%for each stimulation
for r = 1:numel(stimROIs);  %dont plot last Roi....
    clear traces ts SEM toPlot CI ts;

    for c=1:numel(stimon)-1;
        subplot_tight(numel(useROIs),numel(stimon)-1,i)
        %extract traces
        traces=(signals.rois(useROIs(r)).dFF(TrialIndx,:));
       
        %if we're baselining, apply bl correction
        if baseline~=0;
            traces=bsxfun(@minus,traces,mean(traces(:,baseline),2));
        end
        
        %smooth traces
        traces=smoothrows(traces,smofactor);
        t=[1:length(traces)]/FPS;
        toPlot=mean(traces);
        try
            if r==c;
                plot(   t(   round(stimon(c)*FPS)  : round((stimon(c+1)*FPS)+fex)   )   ,   toPlot(round(stimon(c)*FPS): round((stimon(c+1)*FPS)+fex)),'r','LineWidth',LW)
            else
                plot(   t(   round(stimon(c)*FPS)  : round((stimon(c+1)*FPS)+fex)   )   ,   toPlot(round(stimon(c)*FPS): round((stimon(c+1)*FPS)+fex)),'k','LineWidth',LW)
            end
        catch
            if r==c;
                plot(   t(   round(stimon(c)*FPS)  : end   )   ,   toPlot(round(stimon(c)*FPS): end),'r','LineWidth',LW)
            else
                plot(   t(   round(stimon(c)*FPS)  : end   )   ,   toPlot(round(stimon(c)*FPS):end),'k','LineWidth',LW)
            end
        end
  
        
        
    i = i + 1;
    
    y(c,:)=ylim;
    
    axis square
    axis off
%    ylim([-1 1])

    end

    miny=min(y(:,1));
    maxy=max(y(:,2));
    for k=istart:istart+c-1;
           subplot_tight(numel(useROIs),numel(stimon)-1,k)
           ylim([miny maxy]);
    end
    

    istart=i;
    
end