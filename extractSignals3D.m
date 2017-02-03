function Signals=extractSignals3D(expName,alignfile,segmentfile,filedir,basename);

debugT = 0; %disables motion correction for debugging

if nargin<5
    basename='';
end


savename=[expName '.mat'];


for j=1:numel(alignfile);
    disp(['Loading Align file ' num2str(j)])
    load(alignfile{j},'-mat');
    load(segmentfile{j},'-mat');
    
    %extract rois, fit into 512 512 and re-linearize
    rois=full(mask);
    rois=reshape(rois,[size(m) size(rois,2)]);
    
    R=zeros(512,512,size(rois,3));
    
    R(hi{j},wi{j},:)=rois;
    
    
    [NPM] = createNPmask(R);  
    
    %store rois in vectorized form
    Depth{j}.ROIs=logical(reshape(R,[512*512 size(R,3)]));
    Depth{j}.NPM=logical(reshape(NPM,[512*512 size(R,3)]));
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

totalcount=0;
for n = 1:length(IMGFILES);
    fprintf(['Loading file ' num2str(n) '...']);
    %load files
    loadTic = tic;
    
    [data] = ScanImageTiffReader([filedir IMGFILES(n).name]).data();
    data = permute(data,[2 1 3]);
    
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
            if debugT == 1
                mcg(:,:,frame)=gi(:,:,frame);
                mcr(:,:,frame)=ri(:,:,frame);
            else
                mcg(:,:,frame)=circshift(gi(:,:,frame),T(frame+totalcount,:));
                mcr(:,:,frame)=circshift(ri(:,:,frame),T(frame+totalcount,:));
            end
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
                
                g_s=mean(mcg(Depth{j}.ROIs(:,ro)==1,:));
                r_s=mean(mcr(Depth{j}.ROIs(:,ro)==1,:));
                
                g_nps=mean(mcg(Depth{j}.NPM(:,ro)==1,:));
                r_nps=mean(mcr(Depth{j}.NPM(:,ro)==1,:));

                
                Depth{j}.green_data(ro,totalcount+1:totalcount+frame)=g_s;
                Depth{j}.red_data(ro,totalcount+1:totalcount+frame)=r_s;  
                
                Depth{j}.green_npdata(ro,totalcount+1:totalcount+frame)=g_nps;
                Depth{j}.red_npdata(ro,totalcount+1:totalcount+frame)=r_nps;     
        end        

    
    clear mcg mcr
    end
    
    
    
    %% update total count
    totalcount=totalcount+(size(gi,3));  %update total count for T vector
    fprintf([' Took ' num2str(toc(loadTic)) 's\n']);
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



