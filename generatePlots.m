function generatePlots_genSeq(signals,TrialIndx,ExpStruct,baseline)
%sequence opt = 1 - all ROIs in order duing each sweep

%find sweep with stims
m=0;n=1;
while m==0;
m=max(ExpStruct.stims{n}{4});
n=n+1;
end

stimon=find(ExpStruct.stims{n-1}{4}>0);





fn=fieldnames(TrialIndx);




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
for n = 1:numel(signals.rois)-1;  %dont plot last Roi....
    clear traces ts SEM toPlot CI ts;
    
    figure()
   
    % fo each condition
    for j = 1:numel(fn)
        
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
    
    % figure out where hologram is on and patch!
    
    
    
    
    
    
    %format plot
    axis square
    xlim([0 t(length(t))])
 %ylim...
  ylabel('dF/F')
  xlabel('seconds')
    
    waitforbuttonpress
    close all
    
    
end