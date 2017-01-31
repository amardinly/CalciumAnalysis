function [Avg First DFF]= makeAvg(dir,FPT,T,stim,stindx,useTrials)
%stindex(1) = control
%stindex(2)= pulse
%stindex(3)=blast

if numel(stindx)==2;
    stindx(3)=0;
end;

Avg.Con =[];
Avg.Pulse=[];
Avg.Blast=[];
DFF.Con=[];
DFF.Pulse=[];
DFF.Blast=[];
countBlast=0;
countPulse=0;
countC=0;

fo=15;

i=1;
for n =1:numel(dir)
    if isempty(strfind(dir(n).name,'.tif'))
        toDel(i)=n;
        i=i+1;
    end;
end;
dir(toDel)=[];

if ~exist('useTrials');
    useTrials=1:length(stim);
end;


totalcount=(FPT*useTrials(1))-FPT;
for n = 1:length(useTrials);
    
    
    
    [gi ri]=bigread3(dir(useTrials(n)).name);
    for z=1:min(size(gi));
        mcg(:,:,z)=circshift(gi(:,:,z),T(z+totalcount,:));
        mcr(:,:,z)=circshift(ri(:,:,z),T(z+totalcount,:));
    end;
    
    mcg=reshape(mcg,[512*512 FPT]);
    mcg=double(mcg)+1;
    nought = mean(mcg(:,1:fo),2)+1;
    
    dff = bsxfun(@minus,mcg,nought);
    dff = bsxfun(@rdivide,dff,nought);
    
    
    
    
    
    
    if stim(useTrials(n))==stindx(2);
        if countPulse==0;
            Avg.Pulse=mcg;
            DFF.Pulse=dff;
        else
            Avg.Pulse=((Avg.Pulse*countPulse)+mcg)/countPulse+1;
            DFF.Pulse=(DFF.Pulse+dff);%/countPulse+1;
        end;
        
        if countPulse  == 1;
            First.Avg.Pulse=Avg.Pulse;
            First.DFF.Pulse=dff;
        end;
        countPulse=countPulse+1;
            
            
        
            

        
    elseif stim(useTrials(n))==stindx(3);
        if countBlast==0
            Avg.Blast=mcg;
            DFF.Blast=dff;
            
        else
            Avg.Blast= ((Avg.Blast*countBlast)+mcg)/countBlast+1;
            DFF.Blast=(DFF.Blast+dff);
        end
        if countPulse  == 1;
            First.Avg.Blast=Avg.Blast;
            First.DFF.Blast=dff;
            
        end;
        
        countBlast=countBlast+1;

        
    elseif stim(useTrials(n))==stindx(1)  %controls
        if countC==0;
            Avg.Con=mcg;
            DFF.Con=dff;
            
            
        else
            
            Avg.Con= ((Avg.Con*countC)+mcg)/countC+1;
            DFF.Con=(DFF.Con+dff);
            
        end
        if countC  == 1;
            First.Avg.Con=Avg.Con;
            First.DFF.Con=dff;
        end;
        countC=countC+1;
    end
    
    clear mcg dff
    
    
    totalcount=totalcount+z;
end

x=DFF.Con;
if ~isempty(x);
DFF.Con=reshape(DFF.Con,[512 512 FPT])/countC;
Avg.Con=reshape(Avg.Con,[512 512 FPT]);
First.Avg.Con=reshape(First.Avg.Con,[512 512 FPT]);
First.DFF.Con=reshape(First.DFF.Con,[512 512 FPT]);
end;


x=DFF.Pulse;
if ~isempty(x);
DFF.Pulse=reshape(DFF.Pulse,[512 512 FPT])/countPulse;
Avg.Pulse=reshape(Avg.Pulse,[512 512 FPT]);
First.DFF.Pulse=reshape(First.DFF.Pulse,[512 512 FPT]);
First.Avg.Pulse=reshape(First.Avg.Pulse,[512 512 FPT]);
end

x=DFF.Blast;
if ~isempty(x);
DFF.Blast=reshape(DFF.Blast,[512 512 FPT])/countBlast;
Avg.Blast=reshape(Avg.Blast,[512 512 FPT]);
First.DFF.Blast=reshape(First.DFF.Blast,[512 512 FPT]);
First.Avg.Blast=reshape(First.Avg.Blast,[512 512 FPT]);

end