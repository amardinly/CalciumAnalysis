function showMovie(mov,stimROIs,cax,HR,savename);
if isempty(HR); HR=1; end;
if ~exist('HR'); HR=1; end;

global ExpStruct;
   seq=ExpStruct.Holo.holoRequests{HR}.Sequence{1};

FPS=30;
sigma=1.2;

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
        
       if n>2; if stim(n,2)<stim(n-1,3); end;
            stim(n,2)=stim(n-1,3);
        end
    end



on=0;
fig=figure();
for j = 1:size(mov,3);
    
        if ~isempty(intersect(j,stim(:,2)));
            on=1;
            [x b p]=intersect(j,stim(:,2));
            currentROI=stim(p,1);

        elseif ~isempty(intersect(j,stim(:,3)));
            on = 0;
            
        end

    
    imagesc(imgaussfilt(mov(:,:,j),sigma))
    colormap(b2r(cax(1),cax(2)))
    axis off
    axis square
    hold on
    
    if on
        co='r';
    else
        co='k';
    end
    
    
    %%
    p=1;
  % plot arrows
    aoff=10;
    alen=20;
    LW=1.5;
    as=6;
    for vj=1:numel(stimROIs(p).rois)
        cen=stimROIs(p).rois(vj).centroid;
        
        
        
        ax=round(cen(1)-aoff-alen):round((cen(1)-aoff));
        ay=round(cen(2)-aoff-alen):round((cen(2)-aoff));
        plot(ax,ay,co,'LineWidth',LW)
        plot([ax(length(ax)) ax(length(ax))-as],[ay(length(ay)) ay(length(ay))],co,'LineWidth',LW)
        plot([ax(length(ax)) ax(length(ax))],[ay(length(ay)) ay(length(ay))-as],co,'LineWidth',LW)
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