function Data=generatePlots(Signals,Data,Exp,theseROIs,opts)

%specifify default options
if nargin<5
    opts.smofactor=3;  %smoothing factoors
    opts.bl=0;         % base line -1 or 0
    opts.blt='start';  %baseline type 'start' or 'stim'  (5 frames pre stime is baseline)
    opts.ploterr=1;    %plot 95% CI or mean only (1/0)
    opts.plotstim=0;   %plot the holographic stimuli (1/0)
    opts.xyview='stim';%plot the full sweep or only the area around the stim ('full or 'stim')
    opts.savefigs=0;   %save figures (1/0);
    opts.zscore=1;     %zscore figure?
    opts.plotshow = 0; %
end

if nargin<4;
    theseROIs=[1:numel(Data.rois)];
end


fn=fieldnames(Exp.trialtype); %get field names
c=copper(numel(fn));          %establish color map

for Q = 1:length(theseROIs);   %For each ROI specified in the input;
    
    roi=theseROIs(Q);          %rois number in order of clikcy assignment
    if opts.plotshow; figure(); end;
    for j = 1:numel(fn)       %for each condition
        theTrials=Exp.trialtype.(fn{j});  %extract traces
        [traces theTrials]=filterForMotion(roi,Exp,Data,Signals,theTrials);
        if opts.smofactor>1;
        traces=smoothrows(traces,opts.smofactor);
        end
        
        %create time vector
        t=[1:size(traces,2)]/Exp.FPS;  %time vectore
        
        if opts.bl;  %if we're baselining the data
            if strcmp(opts.blt,'start')    %if we're baselining from the start
                baseline=[1:floor(Exp.stimtimes(1)*Exp.FPS)];  %baseline frames befrore any stim commences
                traces=bsxfun(@minus,traces,nanmean(traces(:,baseline),2));
            else
                %plot presetime baseline if ROI is targeted, else plot normal baseline
                [i1 i2 i3]=intersect(roi,Exp.targetROI);  %find if this roi is a target rois
                if ~isempty(i1); %if so
                    
                    baseline=floor(Exp.stimtimes(i3,1)*Exp.FPS)-2:floor(Exp.stimtimes(i3,1)*Exp.FPS)-1;  %baseline is the frame before stim comes on
                    
                else
                    baseline=[1:floor(Exp.stimtimes(1)*Exp.FPS)];  %baseline is the begining of the traces
                    
                end
                traces=bsxfun(@minus,traces,nanmean(traces(:,baseline),2)); %subtract baseline
                
            end
        end
        
        %zscore traces
       % if opts.zscore;
       %     traces=nanzscore(traces,[],2);
       % end
        
        %get 95%CI
        SEM = std(traces)/sqrt(size(traces,2));               % Standard Error
        ts = tinv([0.025  0.975],length(SEM)-1);      % T-Score
        CI = abs(ts(1))*SEM;                      % Confidence Intervals
        
        %make toplot vector
        toPlot(:,1)=mean(traces)+CI;
        toPlot(:,2)=mean(traces);
        toPlot(:,3)=mean(traces)-CI;
        
        %plot
        
        if opts.plotshow
            if opts.ploterr;
                plotshaded(t,toPlot,c(j,:))
            else
                plot(t,mean(traces),'color',c(j,:))
            end
            
            hold on
        end
        
        Data.rois(Q).Conditions.(fn{j})=traces;
    end
    
    y=ylim;
    
    if opts.plotshow
        if opts.plotstim;
            for ss=1:size(Exp.stimtimes,1)
                patch([Exp.stimtimes(ss,1) Exp.stimtimes(ss,1) Exp.stimtimes(ss,2) Exp.stimtimes(ss,2)],[y(1) y(2) y(2)  y(1) ],'m','EdgeAlpha',0,'FaceAlpha',.2)
            end
        end;
        %format plot
        axis square
        xlim([0 t(length(t))])
        if opts.zscore
            ylabel('Zscored dF/F');
        else
            ylabel('dF/F');
        end
        xlabel('seconds')
    end
    
    if strcmp(opts.xyview,'stim')
        [i1 i2 i3]=intersect(roi,Exp.targetROI);
        if ~isempty(i1);
            xlim([Exp.stimtimes(i3,1)-1 Exp.stimtimes(i3,2)+3])
        end
    end
    
    
    if opts.savefigs
        savefig(['ROI_' num2str(roi) '.fig'])
    end
    
    if opts.plotshow;
        waitforbuttonpress
        close all
    end
    
            disp(['finished ROI' num2str(Q)])

end



