function showMovie_arrowsflash(mov,stimROIs,cax,HR,triggersweep,pulses,savename);
FPS=30;
if ~exist('pulses'); pulses=0; end;

if isempty(HR); HR=1; end;
if ~exist('HR'); HR=1; end;

global ExpStruct;
 %seq=ExpStruct.Holo.holoRequests{HR}.Sequence{1};

stimTrace=ExpStruct.stims{triggersweep}{4};
   
stimtimes=find(diff(stimTrace)>0)/2000;
stimetimeframe=round(stimtimes*FPS);
   
sigma=.7;

if ~exist('savename')
    save=0;
else
    save=1;
    vw=VideoWriter([savename '.avi'],'Motion JPEG AVI');
    open(vw);
end

disp('extraction stimulation coordinates')
    for n = 1:numel(stimROIs)
        stim(n,1)=n;
        stim(n,2)=round(stimROIs(n).stimsOn*FPS);
        stim(n,3)=round(stimROIs(n).stimsOff*FPS);
        
       %if n>2; if stim(n,2)<stim(n-1,3); end;
       %     stim(n,2)=stim(n-1,3);
       % end
    end


son=0;
on=0;
fig=figure();
for j =1:size(mov,3);
    if pulses;
        if ~isempty(intersect(j,stimetimeframe));
            son=1;
        else
            son=0;
        end;
    else
        son=0;
    end
    
    
    
        if ~isempty(intersect(j,stim(:,2)));
            on=1;
            [x b p]=intersect(j,stim(:,2));
            %currentROI=stim(p,1);

        elseif ~isempty(intersect(j,stim(:,3)));
            on = 0;
            
        end

    
    imagesc(imgaussfilt(mov(:,:,j),sigma))
   % colormap(b2r(cax(1),cax(2)))
   colormap Jet
   caxis([cax(1) cax(2)])
    axis off
    axis square
    hold on
    
    if son
        co='r';
    else
        co='k';
    end
    
    
    %%
  if  on;
  % plot arrows
    aoff=10;
    alen=20;
    LW=1.5;
    as=6;
    for vj=1:numel(stimROIs(p).rois)
     clear ax ay cen

        cen=[mean(stimROIs(p).rois(vj).vert(:,1)) mean(stimROIs(p).rois(vj).vert(:,2))] ;
               

        
        ax=round(cen(1)-aoff-alen):round((cen(1)-aoff));
        ay=round(cen(2)-aoff-alen):round((cen(2)-aoff));
        plot(ax,ay,co,'LineWidth',LW)
        plot([ax(length(ax)) ax(length(ax))-as],[ay(length(ay)) ay(length(ay))],co,'LineWidth',LW)
        plot([ax(length(ax)) ax(length(ax))],[ay(length(ay)) ay(length(ay))-as],co,'LineWidth',LW)
    end
  end
%%
    
    hold off
    drawnow
    pause(0.03)
    
    if save
        h=getframe(fig);
        writeVideo(vw,h.cdata);
    end
    
    
    
    
    
end


if save;
    close(vw);
end;