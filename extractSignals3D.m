function Signals=extractSignals3D(expName,alignfile,filedir,basename);

if nargin<4
    basename='';
end


savename=[expName '.mat'];


for j=1:numel(alignfile);
    disp(['Loading Align file ' num2str(j)])
    load(alignfile{j},'-mat');
    [NPM] = createNPmask(rois);  
    
    %store rois in vectorized form
    Depth{j}.ROIs=logical(reshape(rois,[512*512 size(rois,3)]));
    Depth{j}.NPM=logical(reshape(NPM,[512*512 size(rois,3)]));
    Depth{j}.meanImg=m;
    Depth{j}.T=T;
    Depth{j}.c3=c3;
end

%% BEGIN SIGNAL PROCESSING
disp('Processing Signals')

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
    k=dir(path);k(1:2)=[];
    i=1;
    for n=1:(numel(k))
        fn=k(n).name;
        if regexp(fn,regexptranslate('wildcard',[basename '*.tif']))
            IMGFILES{i}=fullfile(path,  k(n).name);
            i=i+1;
        end;
    end;
    nn = loadStart:(numToLoad+loadStart-1);
    IMGFILES=IMGFILES(nn);
end
fprintf([ num2str(numel(IMGFILES)) ' Files Detected... \n']);

totalcount=0;
for n = 1:length(IMGFILES);
    disp(['Loading file ' num2str(n)]);
    %load files
    tic
    
    [data] = ScanImageTiffReader([filedir IMGFILES(1).name]).data();
    if n ==1;
        MD = ScanImageTiffReader([filedir IMGFILES(1).name]).metadata();
        SI=parseSI5Header(MD);
    end
    
    g=data(:,:,1:2:end);
    r=data(:,:,2:2:end);
    
       
   
            
    
    %apply motion correction
    
    for j=1:numel(Depth);
       gi=g(:,:,j:(numel(Depth)):end); %exptract depth information
       ri=r(:,:,j:(numel(Depth)):end);
        
        T=Depth{j}.T;
        for frame=1:(size(gi,3));
        mcg(:,:,frame)=circshift(gi(:,:,frame),T(frame+totalcount,:));
        mcr(:,:,frame)=circshift(ri(:,:,frame),T(frame+totalcount,:));
        end;  
   
        %save MC mean images in both channels
        Depth{j}.meanGreen(:,:,n)=(mean(mcg,3));
        Depth{j}.meanRed(:,:,n)=(mean(mcr,3));
   
   
        %vectorize
        mcg=reshape(mcg,[512*512 frame]);
        mcg=double(mcg);
        
        mcr=reshape(mcr,[512*512 frame]);
        mcr=double(mcr);
        
        
        %extract signals        
        for ro=1:size(Depth{j}.ROIs,2);
                
                g_s=mean(mcg(find(Depth{j}.ROIs(:,ro)==1),:));
                r_s=mean(mcr(find(Depth{j}.ROIs(:,ro)==1),:));
                
                g_nps=mean(mcg(find(Depth{j}.NPM(:,ro)==1),:));
                r_nps=mean(mcr(find(Depth{j}.NPM(:,ro)==1),:));

                
                Depth{j}.green_data(ro,totalcount+1:totalcount+frame)=g_s;
                Depth{j}.red_data(ro,totalcount+1:totalcount+frame)=r_s;  
                
                Depth{j}.green_npdata(ro,totalcount+1:totalcount+frame)=g_s;
                Depth{j}.red_npdata(ro,totalcount+1:totalcount+frame)=r_s;     
        end        

    
    clear mcg mcr
    end
    
    
    
    %% update total count
    totalcount=totalcount+(size(gi,3));  %update total count for T vector
    toc
end


%reshape rois and masks 
for j=1:numel(alignfile);
  
    A=Depth{j}.ROIs;
    Depth{j}.ROIs=reshape(A,[512 512 size(A,2)]);
    
    A=Depth{j}.NPM;
    Depth{j}.NPM=reshape(A,[512 512 size(A,2)]);
  
end

for j=1:numel(Depth);
    
    Signals(j).Depths=Depth{j};
end

Signals(1).MD=MD;

disp('Saving Work')
save(savename,'Signals','-v7.3')



