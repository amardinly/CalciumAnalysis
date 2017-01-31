function rawStimMovie(data,cax,FPT,ExpStruct,ifi,opts,save,rect,sw)
%opts = [] for intesnity movie;  'baseline' for Fo = prestim period,
%'prcnt' for Fo = 30th percnetile of movie

if ~exist('rect') || isempty(rect)
    rect(1)=1;
    rect(2)=1;
    rect(3)=511;
    rect(4)=511;
end

if ~exist('sw')
    sw=1;
end

hi=rect(1):rect(1)+rect(3);
wi=rect(2):rect(3)+rect(4);

data=double(data);
cmap = 'gray';  %cmap for movie
HRN = 1;  % HoloRequesst Number
w=3;  %rolling avg of N frames
filter = 1; %apply guassian filter to image?
nfil =1;  %size of gaussian filter
Fs=2000;
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

stimtime=find(diff(ExpStruct.stims{sw}{:,7})==1);

startAt = round((stimtime(1)/Fs)*FPS);
changeAfter = round(((stimtime(2)-stimtime(1))/Fs)*FPS);
startAt=startAt-offset;


start=0;
holoN=0;

if ~isempty(opts)
    if strcmp(opts,'baseline')
        Fo=mean(data(:,:,1:startAt),3);
        
    elseif strcmp(opts,'prcnt')
        Fob=reshape(data,[512*512 FPT]);
        for n = 1:length(Fob);
            Fo(n)=prctile(Fob(n,:),p);
        end;
        Fo=reshape(Fo,[512 512]);
    end
    
    for n =1:FPT;
        Dff(:,:,n)=(double(data(:,:,n)) - Fo) / mean(mean(Fo));
    end;
    data=Dff;
end







  %%
seq=ExpStruct.Holo.holoRequests{HRN}.Sequence{1};
ro=(ExpStruct.Holo.holoRequests{1}.rois);

%ExpStruct.Holo.holoRequests{1}.rois
%ExpStruct.Holo.ROIdata.rois.vertices

ch(1)=startAt;
for z=2:length(seq)+1;
    ch(z)=ch(z-1)+changeAfter;
end;

i=1;
 for n=1:FPT-w;
     
     if n == startAt;
          start=1;
          %holoN=holoN+1;
     end;
    
     
 
     if filter
     k=imgaussfilt(mean(data(:,:,n:n+w),3),nfil);
     imagesc(k)
     else
     imagesc(mean(data(:,:,n:n+w),3))
     end
     
    
    if filter
        k=imgaussfilt(mean(data(:,:,n:n+w),3),nfil);
        imagesc(k)
    else
        imagesc(mean(data(:,:,n:n+w),3))
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
        
        
    dispROI=ro{seq(holoN)};
    if strcmp(mark,'circle')
     
    for q=1:numel(dispROI);    
    [xc yc]=getmidpointcircle(ExpStruct.Holo.ROIdata.rois(dispROI(q)).centroid(1),ExpStruct.Holo.ROIdata.rois(dispROI(q)).centroid(2),cr);
    plot(xc,yc,'r')
    end;
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
        
        
       for q=1:numel(dispROI) 
      cen=ExpStruct.Holo.ROIdata.rois(dispROI(q)).centroid;  
      ax=round(cen(1)-aoff-alen):round((cen(1)-aoff));  
      ay=round(cen(2)-aoff-alen):round((cen(2)-aoff));  
      plot(ax,ay,co,'LineWidth',LW)
      plot([ax(length(ax)) ax(length(ax))-as],[ay(length(ay)) ay(length(ay))],co,'LineWidth',LW)
      plot([ax(length(ax)) ax(length(ax))],[ay(length(ay)) ay(length(ay))-as],co,'LineWidth',LW)
       end
    end
   
    
    
    end;
    caxis(cax)
    colormap(cmap);
    axis square
    axis off
         if save
            h=getframe;
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
     