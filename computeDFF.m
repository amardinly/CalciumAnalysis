function Data=computeDFF(Signals,Exp)


nstart=0;
for d=1:numel(Signals);
    
    
    
    signals=Signals(d).Depths.green_data;
    npsignals=Signals(d).Depths.green_npdata;
    signals=signals-(Exp.NPweight*npsignals);
    
    for n=1:size(signals,1)
        Data.rois(n+nstart).depth=d;
  
        Data.rois(n+nstart).sweeps=reshape(signals(n,:),[Exp.FPT size(signals,2)/Exp.FPT ])';

        Fo = prctile(Data.rois(n).sweeps(:),Exp.pctile);

        dF=bsxfun(@minus,Data.rois(n+nstart).sweeps,Fo);
        
        
        Data.rois(n+nstart).dFF=bsxfun(@rdivide,dF,Fo);
        
        
            
    end;
    
    nstart=nstart+n;
    
end