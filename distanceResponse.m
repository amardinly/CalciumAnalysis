function [d response]=distanceResponse(signals,stimROIs,ROIs,trials,BL)
FPS=30; shift=4;


i=1;
for n = 1:numel(stimROIs)  %for each stim
    s=stimROIs(n).centroid;
    t= round(stimROIs(n).stimsOn*FPS)+shift:round(stimROIs(n).stimsOff*FPS)+shift;
   
    for r=1:numel(signals.rois);
    c=signals.rois(r).centroid;
    %calculate the distance between the stim centroid and the ROI centroid
    d(i)=calcDist(s,c);
    traces=smoothrows(signals.rois(r).dFF(trials,:),10);

    if ~exist('BL'); base=0; else base=mean(traces(BL)); end;
    
    traces=traces-base;
    traces=(mean(traces));
   % traces=traces/max(traces);
    try
    response(i)=max(traces(t));
    end
    i=i+1;
    end
    
end

if length(d)~=length(response);
    m=min([length(d) length(response)]);
    d=d(1:m); response=response(1:m);
end


figure()
scatter(d,response,250,'.');
xlabel('distance (um)')
ylabel('Max dF/F')