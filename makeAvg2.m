function [Avg First ]= makeAvg2(dir,FPT,T,ExpStruct,useTrials,trialBegin)

%trialBegin specifies the physDaq trials to start at
%useTrials is an index that refers to the tif files.  use trialbegin to
%offset any differences.  if everthing is synched up properly, trialBegin
%does not need to be specified


if ~exist('trialBegin') || isempty(trialBegin);
    trialBegin=1;
end;

if ~exist('useTrials') || isempty(useTrials);
    useTrials=1:length(ExpStruct.stims);
end;

stim = ExpStruct.stim_tag(useTrials+trialBegin-1);
u=unique(stim);

for n =1:numel(u);
    vnam{n}=genvarname(['condition' num2str(u(n))]);
    fieldname{n}=strcat(vnam{n});
    counters(n)=0;
    eval([strcat('Avg.',vnam{n}) '=[];']);
end



i=1;
for n =1:numel(dir)
    if isempty(strfind(dir(n).name,'.tif'))
        toDel(i)=n;
        i=i+1;
    end;
end;
dir(toDel)=[];



totalcount=(FPT*useTrials(1))-FPT;
for n = 1:length(useTrials);
    
    [gi ri]=bigread3(dir(useTrials(n)).name);
    
    for z=1:min(size(gi));
        mcg(:,:,z)=circshift(gi(:,:,z),T(z+totalcount,:));
        mcr(:,:,z)=circshift(ri(:,:,z),T(z+totalcount,:));
    end;
    
    mcg=reshape(mcg,[512*512 FPT]);
    mcg=double(mcg);
    
    thisStim=stim(n);
    [a b c]=intersect(thisStim,u);
    
    
    if counters(c) ==0;
        eval(['Avg.(fieldname{c}) =mcg;']);
        eval(['First.Avg.(fieldname{c})=mcg;']);
    else
        eval(['((Avg.(fieldname{c})*counters(c) )+mcg)/counters(c)+1;']);
    end;
    counters(c) =  counters(c) +1;
    
    
    
    clear mcg
    totalcount=totalcount+z;
    
end
    
 
for n = 1:length(fieldname)
eval(['Avg.(fieldname{n})=reshape(Avg.(fieldname{n}),[512 512 FPT]);'])
eval(['First.Avg.(fieldname{n})=reshape(First.Avg.(fieldname{n}),[512 512 FPT]);'])
end