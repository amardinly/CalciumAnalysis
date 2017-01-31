function makeDFFanimation(signals,FN,FPS,smo,rang)

splay = 0;
if ~exist('FN')
    errordlg('Please Select Field Number')
end

 if ~exist('FPS')
     FPS=30;
 end
 if ~exist('smo')
     smo=2;
 end
 if ~exist('rang')
     rang=10; %frames
 end
 
 
 NAMs=fieldnames(signals.rois);
 %Get mean Values
 for n = 1:numel(signals.rois)
     meanVals(n,:)=mean(signals.rois(n).(NAMs{FN}));
 end
 
 meanVals=smoothrows(meanVals,smo);
  
 
 
 ymi=-.5;
 yma= 1;
 if splay == 1;
     yrange=yma-ymi;
     for nr=1:size(meanVals,1);
        meanVals(nr,:)=meanVals(nr,:)-(yrange*(nr-1));   
     end
     ymi=ymi-(yrange*(nr-1));
 end
 
  plot([1:length(meanVals)-rang]/FPS,meanVals(:,1:length(meanVals)-rang)','k');

 for f = 1:length(meanVals)-rang;  % show each frame
     

   %  plot([f:f+rang-1]/FPS,meanVals(:,f:f+rang-1)');
     xlabel('seconds')
     ylabel('DF/F')
     ylim([ymi yma])
     xlim([f/FPS (f+rang-1)/FPS])
     hold on
     
 pause(1/FPS)    
 end
 
 
     