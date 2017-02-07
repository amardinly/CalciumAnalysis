function img2=adjustPhase(img,xshift,start,plotopt);


if nargin<3;
    start=1;
    plotopt=0;
elseif nargin<4;
    plotopt=0;
end



img2=img;

i=1;
for j=1:size(img,1)

  if start==i;
      img2(j,:)=circshift(img(j,:),[0 xshift]);
  else
      img2(j,:)=img(j,:);
  end
  
  
  if i == 1;
      i=2;
  elseif i == 2;
      i=1;
  end
    
    
    
    
end

if plotopt
figure()
subplot(1,2,1)
imagesc(img);
axis square
subplot(1,2,2)
imagesc(img2);
axis square
end