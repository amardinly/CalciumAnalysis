% analyze parameter spaces with 3 PV neurons
load('20160328_3475_FOV1.mat')
outmat1=outmat;
load('20160328_3475_FOV2.mat')
outmat2=outmat;
load('20160328_3475_FOV3.mat')
outmat3=outmat;
i=1;
for n = 1:3
    Values(:,i)=outmat1(n).data(:,5);
    i=i+1;
    Values(:,i)=outmat2(n).data(:,5);
    i=i+1;
    Values(:,i)=outmat3(n).data(:,5);
    i=i+1;
end

meanV=mean(Values');
stdV=std(Values')/sqrt(size(Values,2));

%% goal is to plot by stim times

theData=outmat1(n).data(:,1:4);
%%
i=find( (theData(:,1)==250));
v=find( theData(:,3)==1);
idx=intersect(i,v);
m=meanV(idx);
st=stdV(idx);
[s i]=sort(theData(idx,2))

errorbar(s,m(i),st(i))
hold on
xlabel('Power (mW)')
ylabel('Evoked DF/F')
L1='250 ms, Target 1 Cell';
%%
i=find( (theData(:,1)==250));
v=find( theData(:,3)==2);
idx=intersect(i,v);
m=meanV(idx);
st=stdV(idx);
[s i]=sort(theData(idx,2))


if numel(i)>4
    for n=1:length(i)/2;
        mm(n)=mean([m(n) m(n+1)]);
        ss(n)=mean([st(n) st(n+1)]);
       
    end
e=1:2:max(i)
errorbar(s(e),mm,ss)
else
    errorbar(s,m(i),st(i))
end
L2='250 ms, Target 2 Cell';

%%

i=find( (theData(:,1)==250));
v=find( theData(:,3)==3);
idx=intersect(i,v);
m=meanV(idx);
st=stdV(idx);
[s i]=sort(theData(idx,2))


if numel(i)>4
    for n=1:length(i)/2;
        mm(n)=mean([m(n) m(n+1)]);
        ss(n)=mean([st(n) st(n+1)]);
       
    end
e=1:2:max(i)
errorbar(s(e),mm,ss)
else
    errorbar(s,m(i),st(i))
end
L2='250 ms, Target 3 Cells';

%%
i=find( (theData(:,1)==50));
v=find( theData(:,3)==1);
idx=intersect(i,v);
m=meanV(idx);
st=stdV(idx);
[s i]=sort(theData(idx,2))


if numel(i)>4
    for n=1:length(i)/2;
        mm(n)=mean([m(n) m(n+1)]);
        ss(n)=mean([st(n) st(n+1)]);
       
    end
e=1:2:max(i)
errorbar(s(e),mm,ss)
else
    errorbar(s,m(i),st(i))
end
L2='50 ms, Target 1 Cell';

%%
%%
i=find( (theData(:,1)==50));
v=find( theData(:,3)==2);
idx=intersect(i,v);
m=meanV(idx);
st=stdV(idx);
[s i]=sort(theData(idx,2))


if numel(i)>4
    for n=1:length(i)/2;
        mm(n)=mean([m(n) m(n+1)]);
        ss(n)=mean([st(n) st(n+1)]);
       
    end
e=1:2:max(i)
errorbar(s(e),mm,ss)
else
    errorbar(s,m(i),st(i))
end
L2='50 ms, Target 2 Cells';
%%
%%
i=find( (theData(:,1)==50));
v=find( theData(:,3)==1);
idx=intersect(i,v);
m=meanV(idx);
st=stdV(idx);
[s i]=sort(theData(idx,2))


if numel(i)>4
    for n=1:length(i)/2;
        mm(n)=mean([m(n) m(n+1)]);
        ss(n)=mean([st(n) st(n+1)]);
       
    end
e=1:2:max(i)
errorbar(s(e),mm,ss)
else
    errorbar(s,m(i),st(i))
end
L2='50 ms, Target 1 Cell';