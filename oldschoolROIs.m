function roi=oldschoolROIs(m,hi,wi,mask,depth);
if nargin<5;
    depth=1;
end

hi=hi{depth};
wi=wi{depth};

roi=full(mask);
roi=reshape(roi,[size(m) size(mask,2)]);

z=zeros(512,512);
z(hi,wi)=m;
m=z;


z=zeros(512,512,size(mask,2));
z(hi,wi,:)=roi;
roi=z;

roimask=sum(roi,3);
nrois=size(roi,3);


L=logical(roimask);
m(L)=0;



a=imagesc(log(m));
axis square;
axis off;
colormap gray;
XYP = get(gca,{'xlim','ylim'});  % Get axes limits.




disp('press the x key to exit')
disp('press the r key to place circular roi')
disp('press the e key to place impoly roi')
disp('press the p key to pan or change zoom')
disp('press the u key to undo last ROI')
ch=0;
while ch ~= 120;
   
ch=getkey(1);
    

if ch==114;
    
    h=imellipse;
    waitforbuttonpress
    
    nrois=nrois+1;
    roi(:,:,nrois)=h.createMask;
    roimask=roimask+h.createMask;
    L=logical(roimask);
    mcopy=m;
    
    m(L)=0;
    
    imagesc(log(m));
    axis square;
    axis off;
    colormap gray;
    set(gca,{'xlim','ylim'},XYP)

elseif ch ==101;
    h=impoly;
    waitforbuttonpress
    
    nrois=nrois+1;
    roi(:,:,nrois)=h.createMask;
    roimask=roimask+h.createMask;
    L=logical(roimask);
    mcopy=m;
    
    m(L)=0;
    
    a=imagesc(log(m));
    axis square;
    axis off;
    colormap gray;
    zoom reset
    set(gca,{'xlim','ylim'},XYP)

elseif ch==112
    
    %needs while loops
    
    pause
    
    XYP = get(gca,{'xlim','ylim'});  % Get axes limits.

elseif ch==117;
    
    m=mcopy;
    roi(:,:,nrois)=[];
    nrois=nrois-1;
    roimask=sum(roi,3);
    L=logical(roimask);
    
    m(L)=0;
    
    a=imagesc(log(m));
    axis square;
    axis off;
    colormap gray;
    zoom reset
    set(gca,{'xlim','ylim'},XYP)

end




end

