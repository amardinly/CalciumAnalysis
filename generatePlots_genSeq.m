function generatePlots_genSeq(signals,TrialIndx,ExpStruct,baseline,triggerSweep,useROIs,stimtimes,thisROI)
%sequence opt = 1 - all ROIs in order duing each sweep


if ~exist('useROIs')
    useROIs=length(signals.rois)-1;
end
% 
%%if plotHolo
%stimtimes=findStimTime(useROIs,ExpStruct,triggerSweep);
% offset=0; %seconds
% stimon=find(diff(ExpStruct.stims{triggerSweep}{4})>0);
% stimon=(stimon/2000)-offset;
% 
% stimoff=find(diff(ExpStruct.stims{triggerSweep}{4})<0);
% stimoff=(stimoff/2000)-offset;
% end

fn=fieldnames(TrialIndx);




smofactor=10;
FPS=30;
%initialize color vector = assume that control always comes first in bl;ac
c{1}='k';
c{2}='r';
c{3}='b';
c{4}='m';
c{5}='m';
c{6}='y';
c{7}='c';


%baseline is 0 if you want to leave unpertrubed, if it is entered it should
%be number of frames
if ~exist('baseline')
    baseline=0;
end;



if baseline ~=0;
    baseline=1:baseline;
end


%for each ROI
for Q = 1:length(useROIs);  %dont plot last Roi....
    n=useROIs(Q);
    
    clear traces ts SEM toPlot CI ts;
    n
    figure()
   
    % fo each condition
    for j = 1:numel(fn)
        
        %extract traces
        traces=(signals.rois(n).dFF(TrialIndx.(fn{j}),:));
        
        %create time vector
        t=[1:size(traces,2)]/FPS;
        
        %if we're baselining, apply bl correction
        if baseline~=0;
            traces=bsxfun(@minus,traces,mean(traces(:,baseline),2));
        end
        
        %smooth traces
        traces=smoothrows(traces,smofactor);
        
        %get 95%CI
        SEM = std(traces)/sqrt(size(traces,2));               % Standard Error
        ts = tinv([0.025  0.975],length(SEM)-1);      % T-Score
        CI = abs(ts(1))*SEM;                      % Confidence Intervals
        
        %make toplot vector
        toPlot(:,1)=mean(traces)+CI;
        toPlot(:,2)=mean(traces);
        toPlot(:,3)=mean(traces)-CI;
        
        %plot
        plotshaded(t,toPlot,c{j})
        
        
     
        
    end
        y=ylim;


        
    
    %format plot
    axis square
    xlim([0 t(length(t))])
    ylim(y)
    ylabel('dF/F')
    xlabel('seconds')
    
    waitforbuttonpress
    
%     ylim([-.5 1.5])
%     axis off
%     savefig([num2str(n) '.fig'])
%     
%     
    close all
    
    
end