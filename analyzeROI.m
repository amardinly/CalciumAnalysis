function analyzeROI(signals1,globalTrialInfo,ExpStruct,stimon,lighton)

if ~exist('stimon')
    stimon=[];
end;
if ~exist('lighton')
    lighton=[];
end;

%options:
saveFig=0;
cm='parula';
zscore_sweeps=0;
cax=[-3 3];
display=1;
colorindex{1}='k';
colorindex{2}='r';
colorindex{3}='c';
colorindex{4}='m';
colorindex{5}='g';
smo=0;

unStim=unique(globalTrialInfo.stim);
unHolo=unique(globalTrialInfo.holo);

[a a1 a2]=intersect(0,unHolo);
if a1
    unHolo(a2)=[];
end;

for n = 1:numel(signals1.rois);
    theData=signals1.rois(n).dFF;
    if zscore_sweeps; theData=zscore(theData,[],1); end;
    
    fig1=figure(1);
    fig2=figure(2);
    i=1;ii=1;
    for s=1:numel(unStim);
        for h=1:numel(unHolo)k=combvec(unStim,unHolo);  k=k';
            figure(1)
            subplot(numel(unStim),numel(unHolo),i)
          
            ss=find(globalTrialInfo.stim==unStim(s));
            hs=find(globalTrialInfo.holo==unHolo(h));
            
            thisData=theData(intersect(ss,hs),:);
            imagesc(thisData);
            axis off;
            caxis(cax);
            colormap(cm);
            
            title([ExpStruct.output_names(unHolo(h)) num2str(unStim(s))],'Fontsize',9);
            
            
            
            
            
            if ~smo;
            m(:,1)=mean(thisData)+std(thisData)/sqrt(size(thisData,1));
            m(:,2)=mean(thisData);
            m(:,3)=mean(thisData)-std(thisData)/sqrt(size(thisData,1));
            else
                
            m(:,1)=smoothrows(mean(thisData)+std(thisData)/sqrt(size(thisData,1)),smo);
            m(:,2)=smoothrows(mean(thisData),smo);
            m(:,3)=smoothrows(mean(thisData)-std(thisData)/sqrt(size(thisData,1)),smo);    
                
                
            end
            figure(2);
            subplot(1,numel(unStim),ii)
            hold on
            plotshaded([1:size(m,1)]/30,m,colorindex{h})
            title(num2str(unStim(s)),'Fontsize',9)            
            xlabel('seconds')
            ylabel('dF/F')
            
            
            
            
            
            
            
            
            
            
            i=i+1;
          
            
            if saveFig;
                errodlg('tell alan to write code to autosave figures')
            end;
            
        end;
        
        figure(2);
        hold on;
     %   yy=ylim;
     %   patch([lighton(2) lighton(2) lighton(1) lighton(1)],[yy(2)-.1 yy(2) yy(2) yy(2)-.1],'g','FaceAlpha',.5,'EdgeAlpha',0)
      %  patch([stimon(2) stimon(2) stimon(1) stimon(1)],[yy(2)-.2 yy(2)-.1 yy(2)-.1 yy(2)-.2],'o','FaceAlpha',.5,'EdgeAlpha',0)

        ii=ii+1;
        

    end;
    
    
        set(fig1, 'Position', [10 10 1000 1000])
        set(fig2, 'Position', [700 500 1000 300])
     for z=1:numel(unHolo)
          disp([colorindex{z} ExpStruct.output_names((z+1))]);
     end
      
     vvv=fig2.Children;
     for a=1:numel(vvv);
         yyy(a,:)=vvv(a).YLim;
     end
     ymi=min(yyy(:,1));
     yma=max(yyy(:,2));
     for a=1:numel(vvv);
         subplot(1,numel(unStim),a)
         ylim([ymi yma]);
         yy=ylim;
         patch([lighton(2) lighton(2) lighton(1) lighton(1)],[yy(2)-.1 yy(2) yy(2) yy(2)-.1],'g','FaceAlpha',.5,'EdgeAlpha',0)
         patch([stimon(2) stimon(2) stimon(1) stimon(1)],[yy(2)-.2 yy(2)-.1 yy(2)-.1 yy(2)-.2],'o','FaceAlpha',.5,'EdgeAlpha',0)
     end
     
     
     
      if display; waitforbuttonpress; close all; end;

      
  
end;


