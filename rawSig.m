%% Analysis of 20160302 AM80A-2 FOV2
bname='/global/scratch/mardinly/AM80A-2/20160302_fov2/20160302_1-101';
datadir=('/global/scratch/mardinly/AM80A-2/20160302_fov2/data/');

if ~exist('rect')
rect(1)=1;  rect(2)=511;
rect(3)=1;   rect(4)=511;
end;


load([bname '.segment'],'-mat')
load([bname '.align'],'-mat')

ROImasks=uint16(full(mask));
ROImasks=reshape(ROImasks,[512 512 min(size(ROImasks))]);

wi=rect(1):rect(1)+rect(3);
hi=rect(2):rect(2)+rect(4);
ROImasks=ROImasks(wi,hi,:);
mask=ROImasks;
ROImasks=reshape(ROImasks,[numel(wi)*numel(hi)  min(size(ROImasks))]);
 
dataOpen=dir(datadir);
dataOpen(1:2)=[];

flour=extractSignals(datadir,dataOpen,T,ROImasks,rect);
disp('aboout to save')
save([bname 'signals.mat'],'flour');
save([bname 'signals.mat'],'mask','-append');
disp('saved')

