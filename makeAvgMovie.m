function [AvgMov AvgDFFmov]=makeAvgMovie(savename,Signals,Exp,filedir,basename,phaseAdjust)
if nargin<6;
    phaseAdjust=[];
end

%% BEGIN SIGNAL PROCESSING
disp('Processing Movie')

fprintf('Identifying Files... \n');
if isempty(basename)
    IMGFILES=dir(filedir);
    i=1;
    toDel=[];
    for n =1:numel(IMGFILES)
        if isempty(strfind(IMGFILES(n).name,'.tif'))
            toDel(i)=n;
            i=i+1;
        end;
    end;
    IMGFILES(toDel)=[];
else
    k=dir(filedir);k(1:2)=[];
    IMGFILES=k;
    i=1;
    toDel=[];
    for n=1:(numel(k))
        fn=k(n).name;
        if regexp(fn,regexptranslate('wildcard',[basename '*.tif']))
            fileList{i}=fullfile(path,  k(n).name);
        else
            toDel(i)=n;%IMGFILES{i}=fullfile(path,  k(n).name);
            i=i+1;
        end;
    end;
    IMGFILES(toDel)=[];
    %     nn = loadStart:(numToLoad+loadStart-1);
    %     IMGFILES=IMGFILES(nn);
end
fprintf([ num2str(numel(IMGFILES)) ' Files Detected... \n']);



fn=fieldnames(Exp.trialtype);



for f=1:numel(fn);
    %initialize movie struct
    for k=1:numel(Signals);
        AvgMovie{k}=zeros(512,512,Exp.FPT);
    end
    theseIMGFILES=IMGFILES(Exp.trialtype.(fn{f}));
    
    
    
    
    for n = 1:length(theseIMGFILES);
        
        totalcount = (Exp.trialtype.(fn{1})(n) * Exp.FPT)-Exp.FPT; %find start of the translation matrix
        
        fprintf(['Loading file ' num2str(n) '...']);
        %load files
        loadTic = tic;
        
        [data] = ScanImageTiffReader([filedir IMGFILES(n).name]).data();
        data = permute(data,[2 1 3]);
        
        g=data(:,:,1:2:end);
        clear data;
        
        %apply motion correction
        
        for j=1:numel(Signals);
            gi=g(:,:,j:(numel(Signals)):end); %extract depth information
            nframes=size(gi,3);
            T=Signals(j).Depths.T;
            for frame=1:(size(gi,3));
                mcg(:,:,frame)=circshift(gi(:,:,frame),T(frame+totalcount,:));
            end
            
            clear gi ;
            
            
            if ~isempty(phaseAdjust);
                for q=1:size(mcg,3);
                    mcg(:,:,q)=adjustPhase(mcg(:,:,q),phaseAdjust(j,1),phaseAdjust(j,2),0);
                end
            end
            
            mcg=double(mcg);
            
            
            %%% ASSIGN AVG MOVIES
            AvgMovie{j}=AvgMovie{j}+mcg;
            
            
            
            clear mcg
          
             fprintf([' Took ' num2str(toc(loadTic)) 's\n']);
        end
        clear g;
    end
    
    for k=1:numel(Signals);
        AvgMovie{k}=AvgMovie{k}/n;
    end
    
    
    disp('Saving Work')
    
  
    save([savename '_' fn{f} '.mat'],'AvgMovie','-v7.3')
 

    
    %make dff movie
    for u=1:numel(Signals);
    m=reshape(AvgMovie{u},[size(AvgMovie{u},1)*size(AvgMovie{u},2) size(AvgMovie{u},3)]);
    Fo = mean(m(:,1:floor(Exp.stimtimes(1)*Exp.FPS)),2);
    dff=bsxfun(@minus,m,Fo);
    dff=bsxfun(@rdivide,dff,Fo);
    AvgDFFmov{u}=reshape(dff,size(AvgMovie{u}));
    end
    
    save([savename '_' fn{f} '.mat'],'AvgDFFmov','-append')
    
    clear AvgDFFmov AvgMovie;
end    
    

  