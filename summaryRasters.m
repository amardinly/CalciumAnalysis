function L=summaryRasters(signals,t1,t2)

for n = 1:numel(signals.rois)-1;
    for k =1:numel(signals.rois)-1
    d(n,k)=calcDist(signals.rois(n).centroid,signals.rois(k).centroid);
    end
end

[L,idx,cost] = luczak_scrunch(d);


figure()
subplot(1,3,1)
 for j = 1:numel(signals.rois)-1
   x(j,:)= mean(signals.rois(idx(j)).dFF(t1,:));
 end;
imagesc(smoothrows(zscore(x,[],2),10))
%imagesc(smoothrows(x,10))

c=caxis;

subplot(1,3,2)
 for j = 1:numel(signals.rois)-1
   x2(j,:)= mean(signals.rois(idx(j)).dFF(t2,:));
 end;
imagesc(smoothrows(zscore(x2,[],2),10))
%imagesc(smoothrows(x,10))
caxis(c)

subplot(1,3,3)
title('difference')
imagesc(smoothrows(x-x2,10))
%imagesc(smoothrows(x,10))
caxis(c)