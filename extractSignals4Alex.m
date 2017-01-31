function [signals]= extractSignals4(ROIs,k,FPT,useTrials)
%errordlg('Did you remember to change the u(n)-1????')
npWeight=0.6;
%trialBegin specifies the physDaq trials to start at
%useTrials is an index that refers to the tif files.  use trialbegin to
%offset any differences.  if everthing is synched up properly, trialBegin
%does not need to be specified
if ~isstruct(ROIs); nroi=size(ROIs,3); else nroi=numel(ROIs.rois); end;
%grab tif files

DIR=dir(k);

i=1;
for n =1:numel(DIR)
    if isempty(strfind(DIR(n).name,'.tif'))
        toDel(i)=n;
        i=i+1;
    end;
end;
DIR(toDel)=[];
%dir=dir(useTrials);

%data=nan(nroi,FPT*length(dir));


totalcount=(FPT*useTrials(1))-FPT;
for n = 1:length(useTrials);
    disp(['Loading file ' num2str(n)]);
    %load files
    tic
    [gi ri]=bigread3([k DIR(useTrials(n)).name]);
    %apply motion correction
  % for frame=1:min(size(gi));
  %      mcg(:,:,frame)=circshift(gi(:,:,frame),T(frame+totalcount,:));
      %  mcr=circshift(ri(:,:,frame),T(frame+totalcount,:));
  % end;     
        %vectorize
        mcg=reshape(gi,[512*512 frame]);
        mcg=double(gi);
        
        
        %extract signals        
        if ~isstruct(ROIs);
            for qq=1:nroi;
                x=reshape(ROIs(:,:,qq),[512*512 1]);
                y=mcg(find(x==1),:);
                me=mean(y,1);
                data(qq,totalcount+1:totalcount+frame)=me;
            end
        else
            for qq=1:nroi;
                clear x y
                x=(ROIs.rois(qq).mask);
                x=reshape(x,[512*512 1]);
                y=mcg(find(x==1),:);
                me=mean(y,1);
                
                npx=(ROIs.rois(qq).neuropilmask);
                npx=reshape(x,[512*512 1]);
                npy=mcg(find(x==1),:);
                npme=mean(y,1);
                
                
                me=me-(npWeight*npme);
                data(qq,totalcount+1:totalcount+frame)=me;
            end
        end
        

    
    
    clear mcg
    totalcount=totalcount+min(size(gi));  %update total count for T vector
    toc
    
    
end


totalcount=(FPT*useTrials(1))-FPT;
data(:,1:totalcount)=[];
for n=1:nroi;
x=reshape(data(n,:),[FPT length(useTrials)]);% 

 signals.rois(n).sweeps=x';
end
