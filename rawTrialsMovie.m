function rawTrialsMovie(data,cax,FPT,ExpStruct,ifi,opts,save)
%opts = [] for intesnity movie;  'baseline' for Fo = prestim period,
%'prcnt' for Fo = 30th percnetile of movie
data=double(data);
cmap = 'gray';  %cmap for movie
HRN = 1;  % HoloRequesst Number
w=3;  %rolling avg of N frames
filter = 1; %apply guassian filter to image?
nfil =.5;  %size of gaussian filter
Fs=20000;
FPS=29.96;
p=30;%percentile for Fo
offset=3;
cr=25;


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

  s=size(data);
start=0;
holoN=0;

if ~isempty(opts)
    if strcmp(opts,'baseline')
        Fo=mean(data(:,:,1:startAt),3);
        
    elseif strcmp(opts,'prcnt')
      
        Fob=reshape(data,[512*512 s(3)]);
        for n = 1:length(Fob);
            Fo(n)=prctile(Fob(n,:),p);
        end;
        Fo=reshape(Fo,[512 512]);
    end
    
    for n =1:s(3);
        Dff(:,:,n)=(double(data(:,:,n)) - Fo) / mean(mean(Fo));
    end;
    data=Dff;
end







%%
seq=ExpStruct.Holo.holoRequests{HRN}.Sequence{1};

ch(1)=startAt;
for z=2:length(seq)+1;
    ch(z)=ch(z-1)+changeAfter;
end;

%ExpStruct.Holo.ROIdata.rois.vertices

i=1;
for n=1:s(3)-w;
    
    
    
    if filter
        k=imgaussfilt(mean(data(:,:,n:n+w),3),nfil);
        imagesc(k)
    else
        imagesc(mean(data(:,:,n:n+w),3))
    end
    
    
    if intersect(i,ch)
        holoN=holoN+1;
    end;
    hold on;
    if holoN>length(seq);
        holoN=0;
        hold off
    end
    
    if holoN~=0;
    [xc yc]=getmidpointcircle(ExpStruct.Holo.ROIdata.rois(holoN).centroid(1),ExpStruct.Holo.ROIdata.rois(holoN).centroid(2),cr);
    plot(xc,yc,'r')
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
end

if save;
    close(vw);
end;
