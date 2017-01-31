function signals=computeDFF(signals,method,metric)

if ~(strcmp('baseline',method) || strcmp('prcnt',method))
    errordlg('please select baseline or prcnt')
    return
end





nrois=numel(signals.rois);




for n=1:nrois;
    if strcmp('baseline',method)
        Fo=mean(signals.rois(n).sweeps(:,metric),2);
    elseif strcmp('prcnt',method)
      %  Fo = prctile(reshape(signals.rois(n).sweeps,([size(signals.rois(n).sweeps,1)*size(signals.rois(n).sweeps,2) 1])),metric);
        
        Fo = prctile(signals.rois(n).sweeps',metric);
  %      Fo(1:size(signals.rois(n).sweeps,1))=Fo;
        Fo=Fo';
    end;
    
dF=bsxfun(@minus,signals.rois(n).sweeps,Fo);

signals.rois(n).dFF=bsxfun(@rdivide,dF,Fo);
signals.rois(n).BL=Fo;
end;