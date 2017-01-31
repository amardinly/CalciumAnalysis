function [allDFF allCtrials allStrials] =  trialdff(trials_fluor,FPT,stims)
FPT=240;
s=3;
c=2;


fof=[1:16];
for n = 1:length(trials_fluor)
   data=trials_fluor{n};
   fo=mean(data(:,fof),2); 
   dF=bsxfun(@minus,data,fo); 
   dFF=bsxfun(@rdivide,dF,fo);
   allDFF{n}=dFF;
   
   ctrials=dFF(find(stims==c),:);
   strials=dFF(find(stims==s),:);
   
   allCtrials{n}=dFF(find(stims==c));
   allStrials{n}=dFF(find(stims==s));
   
   plot(medfilt1(mean(ctrials),3),'k')
   hold on
   plot(medfilt1(mean(strials),3),'r')
   waitforbuttonpress
   hold off
   
end


