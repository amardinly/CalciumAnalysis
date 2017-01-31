function rawDualStimMovie(data1,data2,cax,FPT,ExpStruct,ifi,opts,save,rect)
%opts = [] for intesnity movie;  'baseline' for Fo = prestim period,
%'prcnt' for Fo = 30th percnetile of movie
data1=double(data1);
data2=double(data2);


hi = rect(1):rect(1)+rect(3);
wi = rect(2):rect(2)+rect(4);

cmap = 'gray';  %cmap for movie
HRN = 1;  % HoloRequesst Number
w=3;  %rolling avg of N frames
filter1 = 1; %apply guassian filter to image?
nfil1 =1.5;  %size of gaussian filter

filter2=1;
nfil2=.7;


Fs=20000;
FPS=29.96;
p=10;
offset=10;
cr=25;
mark='arrow';  %'circle' or 'arrow'
ON =0;
if save
    vw=VideoWriter([save '.avi'],'Uncompressed AVI'); 
    open(vw); 
   % cmap='gray';
    %cax=[0 255];
end;

stimtime=find(diff(ExpStruct.StimLaserGate)==1);
(stimtime(1)/Fs)*1000;

startAt = round((stimtime(1)/Fs)*FPS);
changeAfter = round(((stimtime(2)-stimtime(1))/Fs)*FPS);
startAt=startAt-offset;


start=0;
holoN=0;

if ~isempty(opts{1})
    if strcmp(opts{1},'baseline')
        Fo=mean(data1(:,:,1:startAt),3);
        
    elseif strcmp(opts{1},'prcnt')
        Fob=reshape(data1,[512*512 FPT]);
        for n = 1:length(Fob);
            Fo(n)=prctile(Fob(n,:),p);
        end;
        Fo=reshape(Fo,[512 512]);
    end
    
    for n =1:FPT;
        Dff(:,:,n)=(double(data1(:,:,n)) - Fo) / mean(mean(Fo));
    end;
    data1=Dff;
end

if ~isempty(opts{2})
    if strcmp(opts{2},'baseline')
        Fo=mean(data2(:,:,1:startAt),3);
        
    elseif strcmp(opts{2},'prcnt')
        Fob=reshape(data2,[512*512 FPT]);
        for n = 1:length(Fob);
            Fo(n)=prctile(Fob(n,:),p);
        end;
        Fo=reshape(Fo,[512 512]);
    end
    
    for n =1:FPT;
        Dff(:,:,n)=(double(data2(:,:,n)) - Fo) / mean(mean(Fo));
    end;
    data2=Dff;
end

data1=data1(wi,hi,:);
data2=data2(wi,hi,:);





  %%
seq=ExpStruct.Holo.holoRequests{HRN}.Sequence{1};
ro=cell2mat(ExpStruct.Holo.holoRequests{1}.rois);
%ExpStruct.Holo.ROIdata.rois.vertices

ch(1)=startAt;
for z=2:length(seq)+1;
    ch(z)=ch(z-1)+changeAfter;
end;

i=1;
fig=figure() ;
set(fig,'Color','k')
 for n=1:FPT-w;
  
     if n == startAt;
          start=1;
          %holoN=holoN+1;
     end;
    
     
     subplot_tight(1,2,1)
     if filter1
     k1=imgaussfilt(mean(data1(:,:,n:n+w),3),nfil1);
     imagesc(k1)
     else
     imagesc(mean(data1(:,:,n:n+w),3))
     end
         hold on;
    subplot_tight(1,2,2)
    if filter2
        k2=imgaussfilt(mean(data2(:,:,n:n+w),3),nfil2);
        imagesc(k2)
    else
        imagesc(mean(data2(:,:,n:n+w),3))
    end
    
    
    if intersect(i,ch)
        holoN=holoN+1;
        ON=0;
    end;
    
    
    hold on;
    if holoN>length(seq);
        holoN=0;
        hold off
    end
    
    if holoN~=0;
        
        
    
    if strcmp(mark,'circle')
    [xc yc]=getmidpointcircle(ExpStruct.Holo.ROIdata.rois(ro(seq(holoN))).centroid(1),ExpStruct.Holo.ROIdata.rois(ro(seq(holoN))).centroid(2),cr);
    plot(xc,yc,'r')
    elseif strcmp(mark,'arrow')
        
     
        % define arrow params
        aoff=15;
        alen=20;
        LW=1.5;
        as=6;
         
        if ON<offset+1;
            co = 'r';
        else 
            co = 'g';
        end;
        
      cen=ExpStruct.Holo.ROIdata.rois(ro(seq(holoN))).centroid;  
      cen(1)=cen(1)-rect(1);
      cen(2)=cen(2)-rect(2);
      ax=round(cen(1)-aoff-alen):round((cen(1)-aoff));  
      ay=round(cen(2)-aoff-alen):round((cen(2)-aoff));  
      
      subplot_tight(1,2,1)
      plot(ax,ay,co,'LineWidth',LW)
      plot([ax(length(ax)) ax(length(ax))-as],[ay(length(ay)) ay(length(ay))],co,'LineWidth',LW)
      plot([ax(length(ax)) ax(length(ax))],[ay(length(ay)) ay(length(ay))-as],co,'LineWidth',LW)
         subplot_tight(1,2,2)
              plot(ax,ay,co,'LineWidth',LW)
      plot([ax(length(ax)) ax(length(ax))-as],[ay(length(ay)) ay(length(ay))],co,'LineWidth',LW)
      plot([ax(length(ax)) ax(length(ax))],[ay(length(ay)) ay(length(ay))-as],co,'LineWidth',LW)
    end
   
    
    
    end;
    subplot_tight(1,2,1)
    caxis(cax{1})
    colormap(cmap);
    axis square
    axis off
      subplot_tight(1,2,2)
    caxis(cax{2})
    colormap(cmap);
    axis square
    axis off
    
    
    
         if save
            h=getframe(fig);
            writeVideo(vw,h.cdata);  
         end
     
     pause(ifi)
      i=i+1;
    if i==FPT;
        i=1;
    end;
    ON = ON + 1;
 end
 
 if save;
     close(vw);
 end;
     