function [traces theTrials]=filterForMotion(roi,Exp,Data,Signals,theTrials);
DISCARD_THRESHOLD=4;  %or 4.7 um motion (at z1.5)

traces=(Data.rois(roi).dFF(theTrials,:)); %get all traces from a condition

depth=Data.rois(roi).depth;

T=Signals(depth).Depths.T;
T=sum(abs(T'));
T=reshape(T,[length(T)/Exp.FPT Exp.FPT ]);



T=T(theTrials,:);

T2(T<DISCARD_THRESHOLD)=0;
T2=logical(T2);

traces(T2)=nan;

mT=mean(T,2);
mT(mT<DISCARD_THRESHOLD)=0;
mT=logical(mT);
theTrials=theTrials(mT);