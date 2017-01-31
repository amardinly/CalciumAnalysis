s=size(m,3);
g1=m(:,:,1:4:s);
g2=m(:,:,2:4:s);
g3=m(:,:,3:4:s);
g4=m(:,:,4:4:s);
s2=size(g1,3);

cax=[0 600];
w=3;
savename='3DMOV_example';


    vw=VideoWriter([savename '.avi'],'Uncompressed AVI');
    open(vw);

    
for j=1:s2-w;
fig=        figure();

    subplot_tight(2,2,1)
    imagesc(mean(g1(:,:,j:j+w),3))
    axis off
    caxis(cax)
    subplot_tight(2,2,2)
    imagesc(mean(g2(:,:,j:j+w),3))
    axis off
    caxis(cax)
    
    subplot_tight(2,2,3)
    imagesc(mean(g3(:,:,j:j+w),3))
    axis off
    caxis(cax)
    
    subplot_tight(2,2,4)
    imagesc(mean(g4(:,:,j:j+w),3))
    axis off
    caxis(cax)
    
    colormap gray
    
        h=getframe(fig);
        writeVideo(vw,h.cdata);
        close all;
end


    close(vw);