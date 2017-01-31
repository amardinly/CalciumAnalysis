function [Avg First signals]= extractSignals3(ROIs,NPM,fnought,k,FPT,T,ExpStruct,useTrials,trialBegin)
usename=1;
%npWeight=0.6;

metric = 'baseline';  % or prcnt
%metric = 'prcnt';


%errordlg('Did you remember to change the u(n)-1????')

%trialBegin specifies the physDaq trials to start at
%useTrials is an index that refers to the tif files.  use trialbegin to
%offset any differences.  if everthing is synched up properly, trialBegin
%does not need to be specified

%ROIS SHOULD ALREADY BE ORDERED USING ORDER ROIS FUNCTIN

DIR=dir(k);

if ~exist('trialBegin') || isempty(trialBegin);
    trialBegin=1;
end;

if ~exist('useTrials') || isempty(useTrials);
    useTrials=1:length(ExpStruct.stims);
end;

stim = ExpStruct.stim_tag(useTrials+trialBegin-1);
u=unique(stim);


if max(u)>numel(ExpStruct.output_names)
    du=(max(u)-numel(ExpStruct.output_names));
u = u - du; 
else 
    du =0;
  
end
  u(u<0)=0;
  u(u==0)=2;
%generate fields in struct
for n =1:numel(u);
    if usename==0;
    vnam{n}=genvarname(['condition' num2str(u(n))]);
    fieldname{n}=strcat(vnam{n});
    else
    vnam{n}=genvarname(ExpStruct.output_names{u(n)});
    fieldname{n}=strcat(vnam{n});
    end
        
    counters(n)=0;  %define counter for oeach psotion
    eval([strcat('Avg.',vnam{n}) '=[];']);  %define empty struct for avg sweeps
end


%grab tif files
i=1;
for n =1:numel(DIR)
    if isempty(strfind(DIR(n).name,'.tif'))
        toDel(i)=n;
        i=i+1;
    end;
end;
DIR(toDel)=[];


%
totalcount=(FPT*useTrials(1))-FPT;
for n = 1:length(useTrials);
     disp(['Loading file ' num2str(n)]);
    %load files
    [gi ri]=bigread3([k DIR(useTrials(n)).name]);
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
    
    if isempty(c)
        c=1;
    end

    

    
    
    if isempty(Avg.(fieldname{c}));  % first sweep
        Avg.(fieldname{c}) =mcg;  %assign the data to avg sweep
        First.(fieldname{c})=mcg; %assign to first sweeps
    else 
        %if counter is not at zero
       ((Avg.(fieldname{c})*counters(c) )+mcg)/counters(c)+1; %update weighted average
    end;
    counters(c) =  counters(c) +1; %incriment counters
    
    %extract signals 
    clear result
    if ~isstruct(ROIs);
        for qq=1:size(ROIs,3);
            if strcmp(metric,'baseline')
            clear x y
            x=(ROIs(:,:,qq));
            x=reshape(x,[512*512 1]);
            y=mcg(find(x==1),:);
            me=mean(y,1);
            Fo=mean(me(fnought));
            df=bsxfun(@minus,me,Fo);
            result(qq,:)=bsxfun(@rdivide,df,Fo);
            signals.rois(qq).(fieldname{c})(counters(c),:)=result(qq,:);
         %   signals.rois(qq).BL=Fo;
            
            clear x y me FO df
            x=(NPM(:,:,qq));
            x=reshape(x,[512*512 1]);
            y=mcg(find(x==1),:);
            me=mean(y,1);
            Fo=mean(me(fnought));
            df=bsxfun(@minus,me,Fo);
            result(qq,:)=bsxfun(@rdivide,df,Fo);
             signals.rois(qq).neuropil.(fieldname{c})(counters(c),:)=result(qq,:);
            
            else
                
                
            clear x y
            x=(ROIs(:,:,qq));
            x=reshape(x,[512*512 1]);
            y=mcg(find(x==1),:);
            me=mean(y,1);
            Fo=prctile(me,30);
            df=bsxfun(@minus,me,Fo);
            result(qq,:)=bsxfun(@rdivide,df,Fo);
            signals.rois(qq).(fieldname{c})(counters(c),:)=result(qq,:);
            signals.rois(qq).BL=Fo;
              
%             clear x y me FO df
%             x=(NPM(:,:,qq));
%             x=reshape(x,[512*512 1]);
%             y=mcg(find(x==1),:);
%             me=mean(y,1);
%             %Fo=prctile(me,30);
%             %df=bsxfun(@minus,me,Fo);
%             result(qq,:)=me;%  bsxfun(@rdivide,df,Fo);
%              signals.rois(qq).neuropil.(fieldname{c})(counters(c),:)=result(qq,:);
               
            end
            
            
            
            
            % result(qq,:)=mean(y,1);
            %distribute signals
      
            
            
            
            
            
        end
    else
        for qq=1:numel(ROIs.rois)
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
            
            Fo=mean(me(fnought));
            df=bsxfun(@minus,me,Fo);
            result(qq,:)=bsxfun(@rdivide,df,Fo);
            
            % result(qq,:)=mean(y,1);
            %distribute signals
            eval(['signals.rois(qq).(fieldname{c})(counters(c),:)=result(qq,:);']);
            
            
        end
    end
    
    eval(['signals.(fieldname{c}){counters(c)}=result;']);

  
    
    
    clear mcg
    totalcount=totalcount+z;  %update total count for T vector
    

end
 
%reshape
for n =1:length(fieldname)
   
    
eval(['Avg.(fieldname{n})=reshape(Avg.(fieldname{n}),[512 512 FPT]);'])
eval(['First.(fieldname{n})=reshape(First.(fieldname{n}),[512 512 FPT]);'])
end