function redResponse(signals,stimROIs,ROIs,trials,dThresh,BL)
FPS=30; shift=0;


i=1;
for n = 1:numel(stimROIs)  %for each stim
    s=stimROIs(n).centroid;
    t= round(stimROIs(n).stimsOn*FPS):round(stimROIs(n).stimsOff*FPS)+5;
    
    for r=1:numel(signals.rois);
        c=signals.rois(r).centroid;
        %calculate the distance between the stim centroid and the ROI centroid
        d=calcDist(s,c);
        
        if d<=dThresh;
            
            red(i)=signals.rois(r).redvalue;
            traces=smoothrows(signals.rois(r).dFF(trials,:),10);
            
            if ~exist('BL'); base=0; else base=mean(traces(BL)); end;
            
            traces=traces-base;
            traces=mean(traces);
            % traces=traces/max(traces);
            
            response(i)=mean(traces(t));
            
            i=i+1;
            
        end
    end
    
end

if length(red)~=length(response);
    m=min([length(d) length(response)]);
    d=d(1:m); response=response(1:m);
end


figure()
scatter(red,response,250,'.');
xlabel('Avg Red Fluo')
ylabel('dF/F')
xlim([0 max(r)])
ylim([min(response) max(response)+.1]);