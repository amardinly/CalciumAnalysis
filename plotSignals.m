function plotSignals(signals,ExpStruct,plotstd,sw,rows,col,smo)
behavior=0;
WAIT=0;
Fs=20000;
FPS=29.96;
yl1=-.5;
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



if ~exist('plotstd')
    plotstd=0;
end;

fn=sort(fieldnames(signals.rois))

if numel(fn)>numel(c);
c=jet(numel(fn));
plotstd=0;
end


nn=length(seq);
nm=1:2:nn*2;
hh=figure()
for n = 1:numel(signals.rois);
  
       if ~WAIT; subplot_tight(rows,col,n); end;
        for k = 1:numel(fn);
            if smo~=0;
            m=smooth(mean(signals.rois(n).(fn{k})),smo);
            m=m';
            else
            m=(mean(signals.rois(n).(fn{k})));
            end
            if ~plotstd
            plot([1:length(m)]/FPS,m,c{k});
            
            elseif plotstd==1
            s=(std(signals.rois(n).(fn{k})));
            s=s/ sqrt(size(signals.rois(n).(fn{k}),1));
               mm(:,1)=m+s;
               mm(:,2)=m;
               mm(:,3)=m-s;
               plotshaded([1:length(mm)]/FPS,mm,c{k})
 
            elseif plotstd==2;
                
                 plot([1:length(m)]/FPS,m,c{k});
                 hold on
                 if strcmp(c{k},'r');
                 plot([1:length(m)]/FPS,smoothrows((signals.rois(n).(fn{k})),smo),'Color',[1 0 0 .2]);
                 else
                 plot([1:length(m)]/FPS,smoothrows((signals.rois(n).(fn{k})),smo),'Color',[0 0 0 .2]);
                 end
                
            end
            hold on 
            clear s m mm 
            axis square
            ylim([yl1 yl2])
            axis off
            
        end
        
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
            patch([stimtime(nm(SeqIndx(xxx))+1) stimtime(nm(SeqIndx(xxx))) stimtime(nm(SeqIndx(xxx))) stimtime(nm(SeqIndx(xxx))+1)]/(Fs/10),[yl2-.1 yl2-.1 yl2 yl2],'m','EdgeAlpha',0,'FaceColor','m','FaceAlpha',.8)
        end
        
        else
        patch([stimtime(2) stimtime(1) stimtime(1) stimtime(2)]/(Fs/10),[yl2-.1 yl2-.1 yl2 yl2],'g','EdgeAlpha',0,'FaceColor','g','FaceAlpha',.7)
        end
        
        if WAIT;
            waitforbuttonpress;
            close all
        end
        
end
 %  set(hh,'Color','k')
