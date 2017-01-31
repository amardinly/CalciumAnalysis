function rasterSignals(signals,ExpStruct,zc,sw,cmap,FPT,smo)

if ~exist('smo')
    smo=3;
end

WAIT=0;
behavior=0;
Fs=20000;
FPS=29.96;
yl1=-.6;
yl2=1;

HRN=1; %holorequest num,ber
c{1}='k';
c{2}='r';
c{3}='c';
c{4}='m';

seq=ExpStruct.Holo.holoRequests{HRN}.Sequence{1};
ro=(ExpStruct.Holo.holoRequests{HRN}.rois);

StimLaserGate=ExpStruct.stims{sw}{7};
stimtime=find(diff(StimLaserGate));


fn=sort(fieldnames(signals.rois));
i=1;
nn=numel(seq);
nm=1:2:nn*2;
figure()
for n = 1:numel(signals.rois)
  
   
        for k = 1:numel(fn);
         if ~WAIT; 
            subplot_tight(numel(signals.rois),numel(fn),i);
         else
            subplot_tight(1,numel(fn),i)
         end;
         
          if ~zc  
          imagesc(smoothrows(signals.rois(n).(fn{k}),smo));
          caxis([yl1 yl2])
          else
          xx=zscore(signals.rois(n).(fn{k}),[],2);
          imagesc(smoothrows(xx,smo));   
          caxis([-3 3])
          end
          colormap(cmap)
          hold on 
          axis off
          
          for xxx=1:numel(ro);
              if intersect(n,ro{xxx});
                  vec(xxx)=1;
              else
                  vec(xxx)=0;
              end;
          end;
          
          [a SeqIndx xxcx]=intersect(seq,find(vec));
        
          if ~behavior
          for xxx=1:numel(SeqIndx);
          %patch(([stimtime(nm(SeqIndx(xxx))+1) stimtime(nm(SeqIndx(xxx))) stimtime(nm(SeqIndx(xxx))) stimtime(nm(SeqIndx(xxx))+1)]/(Fs/10))*FPS,[.5 .5 size(signals.rois(n).(fn{k}),1)+.5 size(signals.rois(n).(fn{k}),1)+.5],'m','EdgeAlpha',.35,'FaceColor','m','FaceAlpha',0)
          end
          else
          patch(([stimtime(2) stimtime(1) stimtime(1) stimtime(2)]/(Fs/10))*FPS,[.5 .5 size(signals.rois(n).(fn{k}),1)+.5 size(signals.rois(n).(fn{k}),1)+.5],'g','EdgeAlpha',.35,'FaceColor','g','FaceAlpha',0)
     
          end
          
          
        
          
          i = i + 1;
        end
           if WAIT;
              waitforbuttonpress;
              close all;
              i=1;
          end;
end
