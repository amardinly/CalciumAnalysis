%i=1;
while i>0
waitforbuttonpress
h=imellipse;
ROIs(:,:,i)=h.createMask;
v=h.getVertices;

hold on
plot(v(:,1),v(:,2),'r');
h.delete;
i=i+1;
end