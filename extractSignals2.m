function [Avg First signals]= extractSignals3(ROIs,dir,FPT,T,ExpStruct,useTrials,trialBegin)

%trialBegin specifies the physDaq trials to start at
%useTrials is an index that refers to the tif files.  use trialbegin to
%offset any differences.  if everthing is synched up properly, trialBegin
%does not need to be specified

%ROIS SHOULD ALREADY BE ORDERED USING ORDER ROIS FUNCTIN

if ~exist('trialBegin') || isempty(trialBegin);
    trialBegin=1;
end;

if ~exist('useTrials') || isempty(useTrials);
    useTrials=1:length(ExpStruct.stims);
end;

stim = ExpStruct.stim_tag(useTrials+trialBegin-1);
u=unique(stim);

%generate fields in struct
for n =1:numel(u);
    vnam{n}=genvarname(['condition' num2str(u(n))]);
    fieldname{n}=strcat(vnam{n});
    counters(n)=0;  %define counter for oeach psotion
    eval([strcat('Avg.',vnam{n}) '=[];']);  %define empty struct for avg sweeps
    eval([strcat('signals.',vnam{n}) '=[];']);  %define empty struct for signals sweeps

end


%grab tif files
i=1;
for n =1:numel(dir)
    if isempty(strfind(dir(n).name,'.tif'))
        toDel(i)=n;
        i=i+1;
    end;
end;
dir(toDel)=[];


%
totalcount=(FPT*useTrials(1))-FPT;
for n = 1:length(useTrials);
    %load files
    [gi ri]=bigread3(dir(useTrials(n)).name);
    %apply motion correction
    for z=1:min(size(gi));
        mcg(:,:,z)=circshift(gi(:,:,z),T(z+totalcount,:));
        mcr(:,:,z)=circshift(ri(:,:,z),T(z+totalcount,:));
    end;
    
    %vectorize
    mcg=reshape(mcg,[512*512 FPT]);
    mcg=double(mcg);
    
    thisStim=stim(n);
    [a b c]=intersect(thisStim,u);
    
    
    if counters(c) ==0;  % first sweep
        eval(['Avg.(fieldname{c}) =mcg;']);  %assign the data to avg sweep
        eval(['First.Avg.(fieldname{c})=mcg;']); %assign to first sweeps
    else 
        %if counter is not at zero
        eval(['((Avg.(fieldname{c})*counters(c) )+mcg)/counters(c)+1;']); %update weighted average
    end;
    counters(c) =  counters(c) +1; %incriment counters
    
    
    
    clear mcg
    totalcount=totalcount+z;  %update total count for T vector
    
end
    
 
%reshape
for n = 1:length(fieldname)
eval(['Avg.(fieldname{n})=reshape(Avg.(fieldname{n}),[512 512 FPT]);'])
eval(['First.Avg.(fieldname{n})=reshape(First.Avg.(fieldname{n}),[512 512 FPT]);'])
end