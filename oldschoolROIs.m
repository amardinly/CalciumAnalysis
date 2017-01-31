function roi=oldschoolROIs(m,hi,wi,mask,depth,ROIdata);
if nargin<5;
    depth=1;
    ROIdata=0;
elseif nargin<6;
    ROIdata=0;
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
if ROIdata
    hold on
    for j=1:numel(ROIdata.rois);
        plot(ROIdata.rois(j).vertices(:,1),ROIdata.rois(j).vertices(:,2),'r');
    end
    hold off
end

iflog=0;
disp('press the x key to exit')
disp('press the r key to place circular roi')
disp('press the e key to place impoly roi')
disp('press the p key to pan or change zoom')
disp('press the u key to undo last ROI')
disp('press the l key to toggle log display')
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
        
        if iflog
            imagesc(log(m));
        else
            imagesc((m));
        end
        axis square;
        axis off;
        colormap gray;
        set(gca,{'xlim','ylim'},XYP)
        if ROIdata
            hold on
            for j=1:numel(ROIdata.rois);
                plot(ROIdata.rois(j).vertices(:,1),ROIdata.rois(j).vertices(:,2),'r');
            end
            hold off
        end
    elseif ch ==101;
        h=impoly;
        waitforbuttonpress
        
        nrois=nrois+1;
        roi(:,:,nrois)=h.createMask;
        roimask=roimask+h.createMask;
        L=logical(roimask);
        mcopy=m;
        
        m(L)=0;
        
        if iflog
            imagesc(log(m));
        else
            imagesc((m));
        end
        axis square;
        axis off;
        colormap gray;
        zoom reset
        set(gca,{'xlim','ylim'},XYP)
        if ROIdata
            hold on
            for j=1:numel(ROIdata.rois);
                plot(ROIdata.rois(j).vertices(:,1),ROIdata.rois(j).vertices(:,2),'r');
            end
            hold off
        end
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
        
        if iflog
            imagesc(log(m));
        else
            imagesc((m));
        end
        axis square;
        axis off;
        colormap gray;
        zoom reset
        set(gca,{'xlim','ylim'},XYP)
        if ROIdata
            hold on
            for j=1:numel(ROIdata.rois);
                plot(ROIdata.rois(j).vertices(:,1),ROIdata.rois(j).vertices(:,2),'r');
            end
            hold off
        end
    elseif ch==108;
        if iflog==1
            iflog=0;
        else
            iflog=1;
        end
        if iflog
            imagesc(log(m));
        else
            imagesc((m));
        end
        axis square;
        axis off;
        colormap gray;
        zoom reset
        set(gca,{'xlim','ylim'},XYP)
        
        if ROIdata
            hold on
            for j=1:numel(ROIdata.rois);
                plot(ROIdata.rois(j).vertices(:,1),ROIdata.rois(j).vertices(:,2),'r');
            end
            hold off
        end
    end
end




end

