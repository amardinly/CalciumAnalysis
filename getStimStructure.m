function [stimROIs stimtimes]=getStimStructure(triggersweep,Exp,hrn);
%function takes a sweep number and an integer to identify the relevant
%holoRequest number.  Outputs stimROIs which is a cell array of length
%sequence containg the stim ROI IDs for each hologram in order of the
%hologram sequence.  Stimtimes returns the initiation (col 1) and cessation
%(col2) times of the stimulation in seconds 



global ExpStruct

if nargin<3;
    hrn=length(ExpStruct.Holo.holoRequests);%holorequest number
end


s=ExpStruct.stims{triggersweep}{4}; %Extract EOM laser sweep
onset = find(diff(s)>0);
offset = find(diff(s)<0);
onset=onset/2000;
offset=offset/2000;  %onset and offset are the arrays of laser on/off in seconds

holoChange=(ExpStruct.stims{triggersweep}{7});
change = find(diff(holoChange)>0);
change=change/2000; %change is an array of the time the SLM was flipped in seconds


TheSequence=ExpStruct.Holo.holoRequests{hrn}.Sequence{1};
roiComposition=ExpStruct.Holo.holoRequests{hrn}.rois; %cell array of the rois targeted by each unique holo in the sequence

for n=1:length(TheSequence);  %go through the whole seuqence one at a time
        thisHolo=TheSequence(n);  % extract the holos on at N time        
        theseROIs=roiComposition{thisHolo}; % figure out which ROI compose the hologram
        
        %extract time window to look for triggers
        TimeStart=change(n) ;
        if n~=length(TheSequence);
            TimeEnd = change(n+1);
        else
            TimeEnd = Exp.FPT/Exp.FPS;
        end
        
        %find laser pulses on after start and off before swithc
        stimTimeStart=find(onset>TimeStart);
        stimTimeEnd=find(offset<TimeEnd);
       
        %extract - column 1 is stim time start for nth holo, column 2 is
        %stim time end
        stimtimes(n,1)=onset(stimTimeStart(1));
        stimtimes(n,2)=offset(stimTimeEnd(end));
        
       %grab and expor tthe ROIs that comprise the hologram that is Nth in
       %the sequence;
        stimROIs(n).rois=theseROIs;
     

        end
end
    