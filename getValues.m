function outmat=getValues(signals,ExpStruct,offset)
%%
% 
%  PREFORMATTED
%  TEXT
% 

%outmat = struct, 1 per neuron
%column 1 is stimulation time
%c2 is stim power
%c3 is number of neurons target (that included)
%c4 is while tareting other cells
%c5 is stim-evoked dff
decayframes=0;
Fs=20000;  %sampling rate
FPS=29.96; %frames per seconds

HRN=1; %holorequest num,ber

%holo sequence
seq=ExpStruct.Holo.holoRequests{HRN}.Sequence{1};
%which rois does the sequence refrece
ro=(ExpStruct.Holo.holoRequests{HRN}.rois);
%index of stims
stLog=ExpStruct.stim_tag(1:100);


%field names
fn=sort(fieldnames(signals.rois));


%length sequence
nn=length(seq);

nm=1:2:nn*2;
outmat=struct;
for n = 1:numel(signals.rois);  %for each ROI
    i=1;
    for k = 1:numel(fn);  %for each stimulation condition
        
        sw=find(stLog==(k+offset));
        sw=sw(1);
        
        StimLaserGate=ExpStruct.stims{sw}{9};
        stimtime=find(diff(StimLaserGate));
        
        m=(mean(signals.rois(n).(fn{k})));
        s=(std(signals.rois(n).(fn{k})));
        s=s/sqrt(size(signals.rois(n).(fn{k}),1));
        
        if  strcmp(fn{k},'control')
            SL=0;
            SP=0;
        else
            [a b]=strtok(fn{k},'ms');
            [x d]=strtok(a,'x');
            SL=str2num(x);
            [e f]=strtok(b,'mW');
            [g h]=strtok(e,'_');
            h(1)=[];
            SP=str2num(h);
        end
        
        
        for z=1:length(nm) %for each pulse
            outmat(n).data(i,1)=SL;
            outmat(n).data(i,2)=SP;
            
            holoTargets=(ro{seq(z)});
            if intersect(n,holoTargets);
                outmat(n).data(i,3)=numel(holoTargets);
                outmat(n).data(i,4)=0;
            else
                outmat(n).data(i,4)=numel(holoTargets);
            end
            
            st=round(([stimtime(nm(z)) stimtime(nm(z)+1)]/(Fs/10))*FPS);
            st(2)=st(2)+decayframes;
            stf=[st(1):st(2)];
            blf=[ st(1)-(length(stf)) :st(1)-1];
            
            outmat(n).data(i,5)=mean(m(stf))-mean(m(blf));
            outmat(n).data(i,6)=mean(s(stf))-mean(s(blf));
            
            
            i=i+1;
        end
        
        
        
        %         for xxx=1:numel(ro);
        %             if intersect(n,ro{xxx});
        %                 vec(xxx)=1;
        %             else
        %                 vec(xxx)=0;
        %             end;
        %         end;
        %
        %         [a SeqIndx xxcx]=intersect(seq,find(vec));
        %
        %
        %         for xxx=1:numel(SeqIndx);
        %             patch([stimtime(nm(SeqIndx(xxx))+1) stimtime(nm(SeqIndx(xxx))) stimtime(nm(SeqIndx(xxx))) stimtime(nm(SeqIndx(xxx))+1)]/(Fs/10),[yl2-.1 yl2-.1 yl2 yl2],'m','EdgeAlpha',0,'FaceColor','m','FaceAlpha',.8)
        %         end
        %
        
        
    end
    
    
    
    
end
