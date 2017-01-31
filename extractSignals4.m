function [signals]= extractSignals4(ROIs,NPM,k,FPT,T,useTrials)

npWeight=0.7;

vROIs=reshape(ROIs,[512*512 size(ROIs,3)]);
vNPM=reshape(NPM,[512*512 size(ROIs,3)]);

%trialBegin specifies the physDaq trials to start at
%useTrials is an index that refers to the tif files.  use trialbegin to
%offset any differences.  if everthing is synched up properly, trialBegin
%does not need to be specified

if ~isstruct(ROIs); nroi=size(ROIs,3); else nroi=numel(ROIs.rois); end;
%grab tif files

DIR=dir(k);

i=1;
toDel=[];
for n =1:numel(DIR)
    if isempty(strfind(DIR(n).name,'.tif'))
        toDel(i)=n;
        i=i+1;
    end;
end;
DIR(toDel)=[];



totalcount=(FPT*useTrials(1))-FPT;
for n = 1:length(useTrials);
    disp(['Loading file ' num2str(n)]);
    %load files
    tic
    [gi ri]=bigread3([k DIR(useTrials(n)).name]);
    %apply motion correction
   for frame=1:(size(gi,3));
        mcg(:,:,frame)=circshift(gi(:,:,frame),T(frame+totalcount,:));
        mcr(:,:,frame)=circshift(ri(:,:,frame),T(frame+totalcount,:));
   end;  
   
    meanGreen(:,:,n)=uint16(max(mcg,[],3));
    meanRed(:,:,n)=uint16(max(mcr,[],3));
   
   
   
        %vectorize
        mcg=reshape(mcg,[512*512 frame]);
        mcg=double(mcg);
        
        mcr=reshape(mcr,[512*512 frame]);
        mcr=double(mcr);
        
        
        %extract signals        
        if ~isstruct(ROIs);
            for r=1:nroi;
                
                thisROI=vROIs(:,r);
                mask=mcg(find(thisROI==1),:);
                me=mean(mask,1);
                
                data(r,totalcount+1:totalcount+frame)=me;
                
                thisNP=vNPM(:,r);
                mask=mcg(find(thisNP==1),:);

                me=mean(mask,1);
                
                NPdata(r,totalcount+1:totalcount+frame)=me;
                
                %thisROI=vROIs(:,r);
                mask=mcr(find(thisROI==1),:);
                me=mean(mask,1);
                
                reddata(r,totalcount+1:totalcount+frame)=me;                
            end
        else
%             for qq=1:nroi;
%                 clear x y
%                 x=(ROIs.rois(qq).mask);
%                 x=reshape(x,[512*512 1]);
%                 y=mcg(find(x==1),:);
%                 me=mean(y,1);
%                 data(qq,totalcount+1:totalcount+frame)=me;
%                  
%                  
%                 npx=(ROIs.rois(qq).neuropilmask);
%                 npx=reshape(x,[512*512 1]);
%                 npy=mcg(find(x==1),:);
%                 npme=mean(y,1);
%                 NPdata(qq,totalcount+1:totalcount+frame)=npme;
%                 
%             end
        end
        

    
    clear mcg mcr
    totalcount=totalcount+(size(gi,3));  %update total count for T vector
    toc
    
    
end

disp(num2str(totalcount));
totalcount=(FPT*useTrials(1))-FPT;
data(:,1:totalcount)=[];
NPdata(:,1:totalcount)=[];
reddata(:,1:totalcount)=[];

for n=1:nroi;
x=reshape(data(n,:),[FPT length(useTrials)]);% 
j=reshape(NPdata(n,:),[FPT length(useTrials)]);% 
v=reshape(reddata(n,:),[FPT length(useTrials)]);% 


signals.rois(n).sweeps=x';
signals.rois(n).NPsweeps=j';
signals.rois(n).redSweeps=v';
end
signals.meanGreen=meanGreen;
signals.meanRed=meanRed;

