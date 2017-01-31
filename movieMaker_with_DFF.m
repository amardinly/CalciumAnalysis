function movieMaker_with_DFF(data1,signals,cax,FPT,ExpStruct,ifi,opts,save,rect,sw,FN,smo)
showFor = 30; %default 15
offset=2; %default 10

ndata=numel(data1);
%set defaults
%opts = [] for intesnity movie;  'baseline' for Fo = prestim period,

if isempty(rect)
    rect(1)=1;
    rect(2)=1;
    rect(3)=511;
    rect(4)=511;
end

hi = rect(1):rect(1)+rect(3);
wi = rect(2):rect(2)+rect(4);

cmap = 'gray';  %cmap for movie
HRN = 1;  % HoloRequesst Number
w=3;  %rolling avg of N frames

filter1 = 1; %apply guassian filter to image?
nfil1 =.75;  %size of gaussian filter

Fs=20000;
FPS=29.96;
p=40;  %'prcnt' for Fo = 30th percnetile of movie

cr=25;
mark='arrow';  %'circle' or 'arrow'

%% Init Df/F components
if ~exist('FN')
    errordlg('Please Select Field Number')
end

 if ~exist('FPS')
     FPS=30;
 end
 if ~exist('smo')
     smo=7;
 end
 if ~exist('rang')
     rang=10; %frames
 end

 
 NAMs=fieldnames(signals.rois);
 %Get mean Values
 for n = 1:numel(signals.rois)
     meanVals(n,:)=mean(signals.rois(n).(NAMs{FN}));
 end
 rang = 90;
 
 %meanVals=bsxfun(@rdivide,meanVals,(max(meanVals,[],2)));
 
 meanVals=smoothrows(meanVals,smo);
 ymi=-.3;
 yma= .7;

%%

if save
    vw=VideoWriter([save '.avi'],'Uncompressed AVI');
    open(vw);
end;


StimLaserGate=ExpStruct.stims{sw}{7};
StimLaserGate(StimLaserGate>0)=1;
stimtime=find(diff(StimLaserGate)==1);

startAt = round((stimtime(1)/(Fs/10))*FPS);  %frame to start stim
if numel(stimtime)>1
    changeAfter = round(((stimtime(2)-stimtime(1))/(Fs/10))*FPS);  %frames to update stim
else
    changeAfter=0;
end
startAt=startAt-offset; %modify by offset


start=0;
holoN=0;

% if an option is specified
if strcmp(opts,'baseline')
    Fo=mean(data1(:,:,1:startAt+offset),3);  %baseline sweeps
elseif strcmp(opts,'prcnt')  %use percentile method
    Fob=reshape(data1,[512*512 FPT]);
    for n = 1:length(Fob);
        Fo(n)=prctile(Fob(n,:),p);
    end;
    Fo=reshape(Fo,[512 512]);
    
end

if ~strcmp(opts,'zscore')
    for n =1:FPT;
        Dff(:,:,n)=(data1(:,:,n) - Fo) ./ mean(mean(Fo));
    end;
    
    data1=Dff;
else
    Fob=reshape(data1,[512*512 FPT]);
    J=zscore(Fob,[],2);
    data1=reshape(J,[512 512 FPT]);
end

data1=data1(wi,hi,:);
timeOn=0;
showHolo =1;
%%
seq=ExpStruct.Holo.holoRequests{HRN}.Sequence{1};
ro=(ExpStruct.Holo.holoRequests{1}.rois);

ch(1)=startAt;
for z=2:numel(stimtime);
    ch(z)=round(stimtime(z)/(Fs/10)*FPS)-offset;   % ch(z-1)+changeAfter;
end;

i=1;ON =0;
fig=figure();
set(fig,'Color','k')  %set background color
for n=1:FPT-w;
    
    if n == startAt;
        start=1;  %start stim
    end;
    
    
    subplot_tight(2,1,1);
    if filter1
        k1=imgaussfilt(mean(data1(:,:,n:n+w),3),nfil1);
        imagesc(k1)
    else
        imagesc(mean(data1(:,:,n:n+w),3))
    end
    
    
    hold on;
    
    if n == 1
    subplot_tight(2,1,2);
    plot([1:length(meanVals)-w]/FPS,meanVals(:,1:length(meanVals)-w)');
    hold off
    end
    % dff animation!
    
    
    
    if intersect(i,ch)
        holoN=holoN+1;
        ON=0;
        showHolo = 1;
        timeOn=0;
        hold on
    end;
    
    if holoN>length(seq);
        holoN=0;
        hold off
    end
    if timeOn>=showFor;
        % holoN=0;
        timeOn =0;
        showHolo = 0;
    end
    
    
    
    if holoN~=0 && showHolo ;  %if there's a holo to display
        dispROI=ro{seq(holoN)};
        
        if strcmp(mark,'circle')
            for q=1:numel(dispROI);
                [xc yc]=getmidpointcircle(ExpStruct.Holo.ROIdata.rois(dispROI(q)).centroid(1),ExpStruct.Holo.ROIdata.rois(dispROI(q)).centroid(2),cr);
                plot(xc,yc,'r')
            end;
        elseif strcmp(mark,'arrow')
            
            
            % define arrow params
            aoff=7;
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
                
                cen(1)=cen(1)-rect(1);
                cen(2)=cen(2)-rect(2);
                
                
                ax=round(cen(1)-aoff-alen):round((cen(1)-aoff));
                ay=round(cen(2)-aoff-alen):round((cen(2)-aoff));
                
                
                subplot_tight(2,1,1);
                plot(ax,ay,co,'LineWidth',LW)
                plot([ax(length(ax)) ax(length(ax))-as],[ay(length(ay)) ay(length(ay))],co,'LineWidth',LW)
                plot([ax(length(ax)) ax(length(ax))],[ay(length(ay)) ay(length(ay))-as],co,'LineWidth',LW)
                
            end
            
        end
        
    end;
    
    subplot_tight(2,1,1);
    caxis(cax)
    colormap(cmap);
    axis square
    axis off
    
    subplot_tight(2,1,2);
    plot([1:length(meanVals)-w]/FPS,meanVals(:,1:length(meanVals)-w)');
     xlabel('seconds')
     ylabel('DF/F')
     ylim([ymi yma])
     xlim([0 FPT/FPS])
     patch([n n+w n+w n]/FPS, [ymi ymi yma yma],'r','FaceAlpha',0.2,'EdgeAlpha',0)
     axis square
     hold off
    
    
    
    %  if ndata==2;
    %  subplot_tight(1,2,2)
    %  caxis(cax{2})
    %   colormap(cmap);
    %   axis square
    %   axis off
    %  end;
    
    
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
    timeOn=timeOn+1;
    
end

if save;
    close(vw);
end;
