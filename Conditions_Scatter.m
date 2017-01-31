function pvals=conditionsScatter(signals,stimtrials,controltrials,timeframes,stimROI,polarflag);
plotopt=1;
if isempty(controltrials)
    blc=1;
else
    blc=0;
end
TD=[]; D=[]; TCD=[];
if numel(timeframes)==2;
    timeframes=timeframes(1):timeframes(2);
end

    d1=signals.rois(stimROI).centroid;

%for each ROI
for r2=1:numel(signals.rois);
    
    stimdeltas= mean(signals.rois(r2).dFF(stimtrials,timeframes),2);
    if ~blc
    condeltas = mean(signals.rois(r2).dFF(controltrials,timeframes),2);
    else
    condeltas = mean(signals.rois(r2).dFF(stimtrials,[1:30]),2);
    end     
%     T=tinv([0.025  0.975],length(stimdeltas)-1);
%     stimCI=stderr(stimdeltas)+T;
%     
%     T=tinv([0.025  0.975],length(condeltas)-1);
%     conCI=stderr(condeltas)+T;
    
    [h p]=ttest2(stimdeltas,condeltas);
    
    Pvals(r2)=p;
    thisDelta(r2)=mean(stimdeltas);
    thisConDelta(r2)=mean(condeltas);
    
    d2=signals.rois(r2).centroid;
    dist(r2)= calcDist(d1,d2);
    
    
end

%thisDelta(stimROI)=[];
%thisConDelta(stimROI)=[];
%dist(stimROI)=[];

D=cat(2,D,dist);
TD=cat(2,TD,thisDelta);
TCD=cat(2,TCD,thisConDelta);




sigIndx=find(Pvals<0.05);

figure()
scatter(TCD,TD,100,'.')
hold on
scatter(TCD(sigIndx),TD(sigIndx),100,'.r')
ylabel('Avg DFF (light)')
xlabel('Avg DFF (control)')
axis square
hold on
xlim([-.5 1.5])
ylim([-.5 1.5])
plot([-.5:1.5],[-.5:1.5],'k--')