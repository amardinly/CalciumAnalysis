function ROIs = makeROI(mask,dim,rect)

if ~exist('rect');
    rect=[ 1 1 511 511];
end

% apply ROIs
wi=rect(1):rect(1)+rect(3);
hi=rect(2):rect(2)+rect(4);
realDim = [512 512];

mask=full(mask);
mask=reshape(mask,[dim min(size(mask))]);

if wi(length(wi))>realDim(1)
    wi =wi -( wi(length(wi))-realDim(1));    
end

if hi(length(hi))>realDim(2)   
        hi =hi -( hi(length(hi))-realDim(2));
end


ROIs=zeros([realDim min(size(mask))]);
ROIs(hi,wi,:)=mask;

excludeOverlap=sum(ROIs,3);
excludeOVerlap=excludeOverlap(:);
j=find(excludeOverlap>1);

R=reshape(ROIs,[size(ROIs,1)*size(ROIs,2) size(ROIs,3)]);
R(j,:)=0;
ROIs=reshape(R,size(ROIs));

    