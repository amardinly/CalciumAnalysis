function [AvgMov AvgDFFmov]=makeAvgMovie(k,T,useTrials,FPT,BL)


DIR=dir(k);

i=1;
for n =1:numel(DIR)
    if isempty(strfind(DIR(n).name,'.tif'))
        toDel(i)=n;
        i=i+1;
    end;
end;
DIR(toDel)=[];

i=1;
DIR=DIR(useTrials);
for n = 1:length(useTrials);
    
    totalcount=(FPT*useTrials(n))-FPT;
    
    disp(['Loading file ' num2str(n)]);
    %load files
    tic
    [gi ri]=bigread3([k DIR(n).name]);
    clear ri;
    %apply motion correction
   for frame=1:min(size(gi));
        mcg(:,:,frame)=circshift(gi(:,:,frame),T(frame+totalcount,:));
   end;     
    
   mcg=double(mcg);
   
   if ~exist('AvgImg');
       AvgImg=mcg;
   else
     %  u=(AvgImg*(i-1))+mcg;
       
       AvgImg=AvgImg+mcg;
   end
   
   
    clear mcg 
    toc
    
    i=i+1;
end

AvgMov=AvgImg/i;

%% Show Av move
% 
% for n = 1:390
% imagesc(AvgImg(:,:,n))
% colormap gray
% caxis([0 8000])
% axis off
% axis square
% pause(0.03)
% end

%%
m=reshape(AvgImg,[size(AvgImg,1)*size(AvgImg,2) size(AvgImg,3)]);

Fo = mean(m(:,BL),2);

dff=bsxfun(@minus,m,Fo);
dff=bsxfun(@rdivide,dff,Fo);

AvgDFFmov=reshape(dff,size(AvgImg));
%% Show Av move
% 
% for n = 1:390
% imagesc(AvgDFFmov(:,:,n))
% colormap gray
% caxis([-1 1])
% axis off
% axis square
% pause(0.03)
% end