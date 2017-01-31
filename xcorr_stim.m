function [dataOut] = xcorr_stim(signals,ExpStruct,FPT)

display =1;
if display; ax=figure(); end;


Fs=29.96;
maxLag=FPT;

rois=1:length(signals.rois);
%C=combnk(rois,2);  %vector of pairwise combinations
t=[1:FPT]/Fs;
i=1;
for n = 1:max(rois);
    sig1=signals.rois(n).dFF;
    s1=mean(sig1);
    for j=1:max(rois);
        sig2=signals.rois(j).dFF;
        s2=mean(sig2);
        
        [acor,lag] = xcorr(s2,s1,maxLag,'Coef');
        
        [k,I] = max((acor));
        dataOut.maxCorr(n,j)=k;
        lagDiff = lag(I);
        dataOut.maxLag(n,j) = lagDiff/Fs;
        
        [k,I] = min((acor));
        dataOut.minCorr(n,j)=k;
        lagDiff = lag(I);
        dataOut.minLag(n,j) = lagDiff/Fs;
        
        dataOut.ZeroLagCorr(n,j) = acor(ceil(length(acor)/2));
        dataOut.Lag500msCorr(n,j)=acor(ceil(length(acor)/2)+15);
        dataOut.FullCorr{n,j}=acor;
        
        if display
            r=subplot(max(rois),max(rois),i);
            plot(lag/Fs,acor);
            xlabel('Lag (s)','Fontsize',7);
            ylabel('Corr','Fontsize',7);
            ylim([-1 1])
            title([num2str(n) ' and ' num2str(j)],'Fontsize',7)
            set(r,'Fontsize',5)
        end
       i=i+1;
    end
     
end
