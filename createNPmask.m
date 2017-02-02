% <<<<<<< HEAD
% function [NeuropilMasks dontuse] = createNPmask(fullMask)
% 
% %if nargin==1 || isempty(rect)
% %    rect=[1 1 511 511];
% %end
% 
% numROI=size(fullMask,3);
% 
% %maskDim=fliplr(rect(3:4)+1);
% %maskOffset = fliplr(rect(1:2))-1;
% 
% %fullMask = reshape(full(mask),[maskDim numROI]);
% %fullMask = cat(3,fullMask,ones(maskDim)); %fake ROI of full frame is numROI+1
% %fullMask = padarray(fullMask,[maskOffset 0],'pre');
% %fullMask = padarray(fullMask,[(512-maskDim-maskOffset) 0],'post');
% 
% %% Remove overlapping regions from ROI masks
% countMatrix = sum(fullMask, 3);                    % determine number of ROIs found in each pixel
% overlap = countMatrix > 1;                         % define regions where ROIs overlap
% fullMask(repmat(overlap, 1, 1, numROI)) = 0;      % remove regions of overlap from ROI masks
% 
% %% SBX method
% g = exp(-(-10:10).^2/2/2^2);
% maskb = conv2(g,g,double(logical(countMatrix)),'same')>.15; %.02                        % dilation for border region around ROIs
% [xi,yi] = meshgrid(1:512,1:512);
% ddd=1;  dontuse=[];
% centroids = zeros([numROI 2]);
% for rindex = 1:numROI
%     try
%     centroids(rindex,:) = fliplr(centerOfMass(fullMask(:,:,rindex))); %center of mass of each ROI fliped to match other convention
%     catch
%     centroids(rindex,:)=nan;
%     dontuse(ddd)=rindex;
%     ddd=ddd+1;
%     end
% end
% 
% %centroids = reshape([ROIdata.rois(ROIindex).centroid], 2, numROIs)';
% for rindex = 1:numROI
%     for neuropilrad = 40:5:100
%         M = (xi-centroids(rindex,1)).^2+(yi-centroids(rindex,2)).^2 < neuropilrad^2;    % mask of pixels within the radius
%         NeuropilMasks(:,:,rindex) = M.*~maskb;                                          % remove ROIs and border regions
%         if nnz(NeuropilMasks(:,:,rindex)) > 4000
%             break
%         end
%     end
% =======
function [NeuropilMasks dontuse] = createNPmask(fullMask)

%if nargin==1 || isempty(rect)
%    rect=[1 1 511 511];
%end

numROI=size(fullMask,3);

%maskDim=fliplr(rect(3:4)+1);
%maskOffset = fliplr(rect(1:2))-1;

%fullMask = reshape(full(mask),[maskDim numROI]);
%fullMask = cat(3,fullMask,ones(maskDim)); %fake ROI of full frame is numROI+1
%fullMask = padarray(fullMask,[maskOffset 0],'pre');
%fullMask = padarray(fullMask,[(512-maskDim-maskOffset) 0],'post');

%% Remove overlapping regions from ROI masks
countMatrix = sum(fullMask, 3);                    % determine number of ROIs found in each pixel
overlap = countMatrix > 1;                         % define regions where ROIs overlap
fullMask(repmat(overlap, 1, 1, numROI)) = 0;      % remove regions of overlap from ROI masks

%% SBX method
g = exp(-(-10:10).^2/2/2^2);
maskb = conv2(g,g,double(logical(countMatrix)),'same')>.15; %.02                        % dilation for border region around ROIs
[xi,yi] = meshgrid(1:512,1:512);
ddd=1;  dontuse=[];
centroids = zeros([numROI 2]);
for rindex = 1:numROI
    try
    centroids(rindex,:) = fliplr(centerOfMass(fullMask(:,:,rindex))); %center of mass of each ROI fliped to match other convention
    catch
    centroids(rindex,:)=nan;
    dontuse(ddd)=rindex;
    ddd=ddd+1;
    end
end

%centroids = reshape([ROIdata.rois(ROIindex).centroid], 2, numROIs)';
for rindex = 1:numROI
    for neuropilrad = 40:5:100
        M = (xi-centroids(rindex,1)).^2+(yi-centroids(rindex,2)).^2 < neuropilrad^2;    % mask of pixels within the radius
        NeuropilMasks(:,:,rindex) = M.*~maskb;                                          % remove ROIs and border regions
        if nnz(NeuropilMasks(:,:,rindex)) > 4000
            break
        end
    end
%>>>>>>> 986d10ee7087b95d10733170fd69b8f1a33f2e80
end