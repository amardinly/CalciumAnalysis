function Avg = extractSingleTrials(dir,FPT,T,stim,stindx)
%stindex(1) = control
%stindex(2)= pulse
%stindex(3)=blast

Avg.Con =[];
Avg.Pulse=[];
Avg.Blast=[];

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



totalcount=0;
for n = 1:length(stim);
    [gi ri]=bigread3(dir(n).name);
    for z=1:min(size(gi));
        mcg(:,:,z)=circshift(gi(:,:,z),T(z+totalcount,:));
        mcr(:,:,z)=circshift(ri(:,:,z),T(z+totalcount,:));
    end;
    
    mcg=reshape(mcg,[512*512 FPT]);
    mcg=double(mcg)+1;
 
    
    
    
    if stim(n)==stindx(2);
        if countPulse==0;
            Avg.Pulse=mcg;
        else
            Avg.Pulse=cat(2,Avg.Pulse,mcg);
        end;
        
      
        countPulse=countPulse+1;
            
            
        
            

        
    elseif stim(n)==stindx(3);
        if countBlast==0
            Avg.Blast=mcg;
            
        else
            Avg.Blast= cat(2,Avg.Blast,mcg);
        end
     
        countBlast=countBlast+1;

        
    elseif stim(n)==stindx(1)  %controls
        if countC==0;
            Avg.Con=mcg;
            
            
        else
            
            Avg.Con= cat(2,Avg.Con,mcg);
            
        end
       
        countC=countC+1;
    end
    
    clear mcg dff
    
    
    totalcount=totalcount+z;
end




Avg.Con=reshape(Avg.Con,[512 512 FPT*countC]);
Avg.Pulse=reshape(Avg.Pulse,[512 512 FPT*countPulse]);
Avg.Blast=reshape(Avg.Blast,[512 512 FPT*countBlast]);

