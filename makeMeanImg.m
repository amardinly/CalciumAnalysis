function img=makeMeanImg(f,T,ExpStruct)

iii=0;
for zz=1:numel(f)
    try
        [gg rr]=bigread3(f{zz});
    catch
        [gg rr]=bigread3(f);
    end

for n = 1:size(gg,3);
    gi(:,:,n+iii)=circshift(gg(:,:,n),T(iii+n,:));
    ri(:,:,n+iii)=circshift(rr(:,:,n),T(iii+n,:));
end
iii=iii+n;
end;


g=mean(gi,3);
r=mean(ri,3);

img=zeros(512,512,3);
img=uint8(img);

g=g/max(max(g));
g=g*255;
g=uint8(g);

r=r/max(max(r));
r=r*255;
r=uint8(r);

img(:,:,1)=r;
img(:,:,2)=g;
imshow(img);

seq=ExpStruct.Holo.holoRequests{1}.Sequence{1};
ro=ExpStruct.Holo.holoRequests{1}.rois;

cr=15;

for n = 1:length(ExpStruct.Holo.ROIdata.rois);
    hold on
   % dispROI=ro{seq(n)};
   % for k4=1:numel(dispROI)
    [xc yc]=getmidpointcircle(ExpStruct.Holo.ROIdata.rois(n).centroid(1),ExpStruct.Holo.ROIdata.rois(n).centroid(2),cr);
    
  %  plot(xc,yc,'b');
   % text(ExpStruct.Holo.ROIdata.rois(n).centroid(1)-15,ExpStruct.Holo.ROIdata.rois(n).centroid(2)-15,num2str(n),'FontSize',14,'Color','c');
   
%   end
   
end